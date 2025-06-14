const { initializeFirebase } = require('../config/firebase');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, DeleteCommand, QueryCommand, PutCommand } = require('@aws-sdk/lib-dynamodb');

class UserService {
  constructor() {
    this.admin = initializeFirebase();
    
    // Initialize DynamoDB client for user data
    const client = new DynamoDBClient({
      region: process.env.AWS_REGION || 'us-east-1',
    });
    this.dynamoDocClient = DynamoDBDocumentClient.from(client);
    this.userTableName = process.env.DYNAMODB_USER_TABLE || 'iwbh-users';
    this.chatTableName = process.env.DYNAMODB_CHAT_TABLE || 'iwbh-chats';
  }

  /**
   * Delete user account completely (Firebase + Database)
   * @param {string} userId - The user ID to delete
   * @param {string} feedback - Optional feedback from user
   * @returns {Promise<Object>} Deletion result
   */
  async deleteUserAccount(userId, feedback = null) {
    const results = {
      firebaseDeleted: false,
      userDataDeleted: false,
      chatDataDeleted: false,
      errors: []
    };

    try {
      // 1. Delete from Firebase Auth (if not a guest user)
      if (!userId.startsWith('guest-')) {
        try {
          await this.admin.auth().deleteUser(userId);
          results.firebaseDeleted = true;
          console.log(`Firebase user ${userId} deleted successfully`);
        } catch (firebaseError) {
          console.error('Firebase deletion error:', firebaseError);
          results.errors.push(`Firebase: ${firebaseError.message}`);
        }
      } else {
        results.firebaseDeleted = true; // Guest users don't exist in Firebase
      }

      // 2. Delete user profile data from DynamoDB
      try {
        await this.deleteUserProfileData(userId);
        results.userDataDeleted = true;
        console.log(`User profile data for ${userId} deleted successfully`);
      } catch (dbError) {
        console.error('Database user data deletion error:', dbError);
        results.errors.push(`User Data: ${dbError.message}`);
      }

      // 3. Delete chat history from DynamoDB
      try {
        await this.deleteUserChatData(userId);
        results.chatDataDeleted = true;
        console.log(`Chat data for ${userId} deleted successfully`);
      } catch (chatError) {
        console.error('Chat data deletion error:', chatError);
        results.errors.push(`Chat Data: ${chatError.message}`);
      }

      // 4. Store feedback if provided
      if (feedback) {
        try {
          await this.storeDeletionFeedback(userId, feedback);
          console.log(`Deletion feedback stored for ${userId}`);
        } catch (feedbackError) {
          console.error('Feedback storage error:', feedbackError);
          // Don't add to errors - feedback storage is optional
        }
      }

      // 5. Log the deletion for audit trail
      await this.logAccountDeletion(userId, results);

      return results;
    } catch (error) {
      console.error('Account deletion error:', error);
      results.errors.push(`General: ${error.message}`);
      return results;
    }
  }

  /**
   * Delete user profile data from DynamoDB
   * @param {string} userId - User ID
   */
  async deleteUserProfileData(userId) {
    try {
      const deleteParams = {
        TableName: this.userTableName,
        Key: { userId }
      };
      
      await this.dynamoDocClient.send(new DeleteCommand(deleteParams));
    } catch (error) {
      // If table doesn't exist, that's okay for development
      if (error.name === 'ResourceNotFoundException') {
        console.log(`User table ${this.userTableName} not found - skipping user data deletion`);
        return;
      }
      throw error;
    }
  }

  /**
   * Delete user chat data from DynamoDB
   * @param {string} userId - User ID
   */
  async deleteUserChatData(userId) {
    try {
      // Query for all chat records for this user
      const queryParams = {
        TableName: this.chatTableName,
        KeyConditionExpression: 'userId = :userId',
        ExpressionAttributeValues: {
          ':userId': userId
        }
      };

      const queryResult = await this.dynamoDocClient.send(new QueryCommand(queryParams));
      
      // Delete each chat record
      if (queryResult.Items && queryResult.Items.length > 0) {
        const deletePromises = queryResult.Items.map(item => {
          const deleteParams = {
            TableName: this.chatTableName,
            Key: {
              userId: item.userId,
              timestamp: item.timestamp
            }
          };
          return this.dynamoDocClient.send(new DeleteCommand(deleteParams));
        });

        await Promise.all(deletePromises);
        console.log(`Deleted ${queryResult.Items.length} chat records for user ${userId}`);
      }
    } catch (error) {
      // If table doesn't exist, that's okay for development
      if (error.name === 'ResourceNotFoundException') {
        console.log(`Chat table ${this.chatTableName} not found - skipping chat data deletion`);
        return;
      }
      throw error;
    }
  }

  /**
   * Store deletion feedback for analysis
   * @param {string} userId - User ID
   * @param {string} feedback - User feedback
   */
  async storeDeletionFeedback(userId, feedback) {
    try {
      const feedbackRecord = {
        userId,
        feedback,
        deletionDate: new Date().toISOString(),
        timestamp: Date.now()
      };

      const params = {
        TableName: 'iwbh-deletion-feedback',
        Item: feedbackRecord
      };

      await this.dynamoDocClient.send(new PutCommand(params));
    } catch (error) {
      console.log('Feedback storage failed (non-critical):', error.message);
      // Don't throw - feedback storage is optional
    }
  }

  /**
   * Log account deletion for audit trail
   * @param {string} userId - User ID
   * @param {Object} results - Deletion results
   */
  async logAccountDeletion(userId, results) {
    const auditLog = {
      userId,
      deletionDate: new Date().toISOString(),
      results,
      timestamp: Date.now()
    };

    console.log('Account deletion audit log:', JSON.stringify(auditLog, null, 2));
    
    // In production, you might want to store this in a dedicated audit table
    // For now, we just log it
  }

  /**
   * Check if user account deletion is in progress
   * @param {string} userId - User ID
   * @returns {Promise<boolean>}
   */
  async isAccountDeletionInProgress(userId) {
    // This could query a "pending deletions" table
    // For now, return false
    return false;
  }
}

module.exports = UserService;
