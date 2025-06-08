const { PutCommand, QueryCommand } = require('@aws-sdk/lib-dynamodb');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { dynamoDocClient } = require('../config/dynamodb');
const openai = require('../config/openai');

const TABLE_NAME = 'UserChats';
const BUCKET_NAME = 'iwbh-user-chats-media';

// Initialize S3 client
const s3Client = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

/**
 * Service for handling chat operations
 */
class ChatService {
  /**
   * Process a user message and generate an AI response
   * @param {string} userId - The user's ID
   * @param {string} message - The user's message
   * @param {boolean} sharedWithPartner - Whether this chat is shared with partner
   * @param {string} fileData - Optional base64-encoded file data
   * @param {string} fileName - Optional file name
   * @returns {Promise<Object>} - The AI response and metadata
   */
  async processChat(userId, message, sharedWithPartner = false, fileData = null, fileName = null) {
    try {
      // Handle file upload if file data is provided
      let fileUrl = null;
      if (fileData && fileName) {
        fileUrl = await this.uploadFileToS3(userId, fileData, fileName);
      }
      
      // Call OpenAI to generate response
      const aiResponse = await this.generateAIResponse(message, fileUrl);
      
      // Extract theme tags (this could be enhanced with more sophisticated analysis)
      const themeTags = this.extractThemeTags(message, aiResponse);
      
      // Create chat record
      const chatRecord = {
        userId,
        timestamp: Date.now(),
        message,
        aiResponse,
        themeTags,
        sharedWithPartner,
        fileUrl // Include the file URL if a file was uploaded
      };
      
      // Save to DynamoDB
      await this.saveChatToDynamo(chatRecord);
      
      return {
        response: aiResponse,
        timestamp: chatRecord.timestamp,
        themeTags,
        fileUrl // Return the file URL to the client
      };
    } catch (error) {
      console.error('Error processing chat:', error);
      throw error;
    }
  }
  
  /**
   * Upload file to S3
   * @param {string} userId - User ID
   * @param {string} fileData - Base64-encoded file data
   * @param {string} fileName - File name
   * @returns {Promise<string>} - URL of uploaded file
   */
  async uploadFileToS3(userId, fileData, fileName) {
    try {
      // Convert base64 data to buffer
      const buffer = Buffer.from(fileData, 'base64');
      
      // Generate unique file path
      const timestamp = Date.now();
      const key = `${userId}/${timestamp}-${fileName}`;
      
      // Set up S3 upload parameters
      const params = {
        Bucket: BUCKET_NAME,
        Key: key,
        Body: buffer,
        ContentType: this.getContentType(fileName)
      };
      
      // Upload to S3
      await s3Client.send(new PutObjectCommand(params));
      
      // Return the file URL
      return `https://${BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
    } catch (error) {
      console.error('Error uploading to S3:', error);
      throw new Error('Failed to upload file');
    }
  }
  
  /**
   * Get content type based on file extension
   * @param {string} fileName - File name
   * @returns {string} - Content type
   */
  getContentType(fileName) {
    const ext = fileName.split('.').pop().toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
  
  /**
   * Generate AI response using OpenAI, potentially with reference to an image
   * @param {string} message - User's message
   * @param {string} fileUrl - Optional URL of uploaded file
   * @returns {Promise<string>} - AI generated response
   */
  async generateAIResponse(message, fileUrl = null) {
    try {
      // Create a content prompt that includes the image URL if one was uploaded
      let promptContent = message;
      if (fileUrl) {
        promptContent += `\n\n[Note: The user shared an image: ${fileUrl}]`;
      }
      
      const completion = await openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          { 
            role: "system", 
            content: "You are a supportive dating coach who helps users navigate romantic relationships with empathy, " +
                    "actionable advice, and a focus on healthy communication. Keep responses concise but helpful."
          },
          { role: "user", content: promptContent }
        ],
        max_tokens: 500
      });
      
      return completion.choices[0].message.content;
    } catch (error) {
      console.error('Error generating AI response:', error);
      throw new Error('Failed to generate AI response');
    }
  }
  
  /**
   * Save chat record to DynamoDB
   * @param {Object} chatRecord - The chat record to save
   * @returns {Promise<void>}
   */
  async saveChatToDynamo(chatRecord) {
    try {
      const params = {
        TableName: TABLE_NAME,
        Item: chatRecord
      };
      
      await dynamoDocClient.send(new PutCommand(params));
    } catch (error) {
      console.error('Error saving to DynamoDB:', error);
      throw new Error('Failed to save chat to database');
    }
  }
  
  /**
   * Extract theme tags from message and response
   * @param {string} message - User message
   * @param {string} response - AI response
   * @returns {Array<string>} - Extracted theme tags
   */
  extractThemeTags(message, response) {
    // This is a simple implementation that can be enhanced
    const combinedText = (message + " " + response).toLowerCase();
    const possibleTags = [
      'communication', 'boundaries', 'conflict', 'dating',
      'relationship', 'emotional', 'trust', 'commitment'
    ];
    
    return possibleTags.filter(tag => combinedText.includes(tag));
  }
  
  /**
   * Generate weekly summary for user
   * @param {string} userId - User ID
   * @returns {Promise<Object>} - Summary of user's recent chats
   */
  async generateWeeklySummary(userId) {
    try {
      // Get recent chats (last 7 days)
      const sevenDaysAgo = Date.now() - (7 * 24 * 60 * 60 * 1000);
      
      const params = {
        TableName: TABLE_NAME,
        KeyConditionExpression: "userId = :userId AND #ts >= :startTime",
        ExpressionAttributeNames: {
          "#ts": "timestamp"
        },
        ExpressionAttributeValues: {
          ":userId": userId,
          ":startTime": sevenDaysAgo
        }
      };
      
      const result = await dynamoDocClient.send(new QueryCommand(params));
      
      if (!result.Items || result.Items.length === 0) {
        return {
          summary: "You haven't had any chats in the past week.",
          insights: []
        };
      }
      
      // Generate summary using OpenAI
      return await this.createSummaryWithOpenAI(result.Items);
    } catch (error) {
      console.error('Error generating weekly summary:', error);
      throw new Error('Failed to generate weekly summary');
    }
  }
  
  /**
   * Create summary with OpenAI based on recent chats
   * @param {Array<Object>} chats - Recent chat records
   * @returns {Promise<Object>} - Summary and insights
   */
  async createSummaryWithOpenAI(chats) {
    try {
      // Format chats for OpenAI prompt
      const chatHistory = chats.map(chat => 
        `User: ${chat.message}\nCoach: ${chat.aiResponse}`
      ).join('\n\n');
      
      const completion = await openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          { 
            role: "system", 
            content: "You are a dating coach assistant. Generate a brief summary and 3-5 key relationship insights based on these recent conversations."
          },
          { 
            role: "user", 
            content: `Here are the recent conversations:\n\n${chatHistory}\n\nProvide a concise weekly summary and key relationship insights for the user.`
          }
        ],
        max_tokens: 700
      });
      
      const response = completion.choices[0].message.content;
      
      // Parse the response into summary and insights
      // This is a simple implementation and could be enhanced
      const parts = response.split('Insights:');
      let summary = response;
      let insights = [];
      
      if (parts.length > 1) {
        summary = parts[0].replace('Summary:', '').trim();
        insights = parts[1].split('\n').filter(line => line.trim().length > 0)
          .map(line => line.replace(/^\d+\.\s*/, '').trim());
      }
      
      return { summary, insights };
    } catch (error) {
      console.error('Error creating summary with OpenAI:', error);
      throw new Error('Failed to create chat summary');
    }
  }
  
  /**
   * Get chat history for a user
   * @param {string} userId - The user's ID
   * @param {number} startTime - Start timestamp (optional)
   * @param {number} endTime - End timestamp (optional)
   * @param {number} limit - Maximum number of records to return (optional)
   * @returns {Promise<Object>} - Chat history items
   */
  async getChatHistory(userId, startTime, endTime, limit = 50) {
    try {
      let keyConditionExpression = "userId = :userId";
      let expressionAttributeValues = {
        ":userId": userId
      };
      
      // Add time range if provided
      if (startTime && endTime) {
        keyConditionExpression += " AND #ts BETWEEN :startTime AND :endTime";
        expressionAttributeValues[":startTime"] = startTime;
        expressionAttributeValues[":endTime"] = endTime;
      } else if (startTime) {
        keyConditionExpression += " AND #ts >= :startTime";
        expressionAttributeValues[":startTime"] = startTime;
      } else if (endTime) {
        keyConditionExpression += " AND #ts <= :endTime";
        expressionAttributeValues[":endTime"] = endTime;
      }
      
      const params = {
        TableName: TABLE_NAME,
        KeyConditionExpression: keyConditionExpression,
        ExpressionAttributeNames: {
          "#ts": "timestamp"
        },
        ExpressionAttributeValues: expressionAttributeValues,
        ScanIndexForward: false, // Return in descending order (newest first)
        Limit: limit
      };
      
      return await dynamoDocClient.send(new QueryCommand(params));
    } catch (error) {
      console.error('Error retrieving chat history:', error);
      throw new Error('Failed to retrieve chat history');
    }
  }
}

module.exports = new ChatService();