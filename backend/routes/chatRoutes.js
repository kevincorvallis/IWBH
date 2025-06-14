const express = require('express');
const chatService = require('../services/chatService');
const UserService = require('../services/userService');

const router = express.Router();

/**
 * POST /api/chat
 * Process a user's chat message and respond with AI-generated advice
 */
router.post('/chat', async (req, res) => {
  try {
    const { userId, message, sharedWithPartner = false, fileData, fileName } = req.body;
    
    // Validate required parameters
    if (!userId || !message) {
      return res.status(400).json({ error: 'Missing required parameters: userId and message are required' });
    }
    
    // Process the chat message, with optional file data
    const result = await chatService.processChat(userId, message, sharedWithPartner, fileData, fileName);
    
    // Return the response
    res.status(200).json(result);
    
  } catch (error) {
    console.error('Error in chat endpoint:', error);
    res.status(500).json({ error: 'Failed to process chat message' });
  }
});

/**
 * GET /api/weekly-summary
 * Generate a summary of the user's recent conversations
 */
router.get('/weekly-summary/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Validate required parameter
    if (!userId) {
      return res.status(400).json({ error: 'Missing required parameter: userId' });
    }
    
    // Generate the weekly summary
    const summary = await chatService.generateWeeklySummary(userId);
    
    // Return the summary
    res.status(200).json(summary);
    
  } catch (error) {
    console.error('Error in weekly summary endpoint:', error);
    res.status(500).json({ error: 'Failed to generate weekly summary' });
  }
});

/**
 * GET /api/chat-history
 * Retrieve chat history for a user
 */
router.get('/chat-history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { startDate, endDate, limit } = req.query;
    
    // Validate required parameter
    if (!userId) {
      return res.status(400).json({ error: 'Missing required parameter: userId' });
    }
    
    // Convert date strings to timestamps if provided
    const startTimestamp = startDate ? new Date(startDate).getTime() : undefined;
    const endTimestamp = endDate ? new Date(endDate).getTime() : undefined;
    const limitNumber = limit ? parseInt(limit, 10) : undefined;
    
    // Get chat history
    const { Items } = await chatService.getChatHistory(userId, startTimestamp, endTimestamp, limitNumber);
    
    // Return the chat history
    res.status(200).json({ history: Items });
    
  } catch (error) {
    console.error('Error in chat history endpoint:', error);
    res.status(500).json({ error: 'Failed to retrieve chat history' });
  }
});

/**
 * DELETE /api/users/:userId
 * Delete user account completely (Firebase + Database)
 */
router.delete('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { feedback } = req.body;
    
    // Validate required parameter
    if (!userId) {
      return res.status(400).json({ error: 'Missing required parameter: userId' });
    }
    
    // Log the deletion request
    console.log(`Account deletion requested for user: ${userId}`, feedback ? `with feedback: ${feedback}` : 'without feedback');
    
    // Initialize the user service
    const userService = new UserService();
    
    // Perform the actual account deletion
    const deletionResults = await userService.deleteUserAccount(userId, feedback);
    
    // Check if deletion was successful
    const isSuccess = deletionResults.firebaseDeleted && 
                     deletionResults.userDataDeleted && 
                     deletionResults.chatDataDeleted;
    
    if (isSuccess) {
      const response = {
        message: 'Account deleted successfully. All user data has been permanently removed.',
        deletionResults: {
          firebase: deletionResults.firebaseDeleted,
          userData: deletionResults.userDataDeleted,
          chatData: deletionResults.chatDataDeleted
        }
      };
      
      // Return 202 Accepted for successful async processing
      res.status(202).json(response);
    } else {
      // Partial failure - some data may still exist
      const response = {
        message: 'Account deletion completed with some errors. Please contact support if issues persist.',
        deletionResults: {
          firebase: deletionResults.firebaseDeleted,
          userData: deletionResults.userDataDeleted,
          chatData: deletionResults.chatDataDeleted,
          errors: deletionResults.errors
        }
      };
      
      // Return 202 but with warning about partial success
      res.status(202).json(response);
    }
    
  } catch (error) {
    console.error('Error in account deletion endpoint:', error);
    res.status(500).json({ 
      error: 'Failed to process account deletion request',
      details: error.message 
    });
  }
});

module.exports = router;
