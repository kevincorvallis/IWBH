const Chat = require('../models/Chat');
const chatService = require('../services/chatService');
const { formatResponse, formatError } = require('../utils/response');
const logger = require('../utils/logger');

/**
 * Get all chats for a user
 */
const getChats = async (req, res, next) => {
  try {
    const userId = req.user?.id || 'guest';
    const { page = 1, limit = 20 } = req.query;
    
    const chats = await chatService.getUserChats(userId, parseInt(page), parseInt(limit));
    
    res.json(formatResponse(true, chats, 'Chats retrieved successfully'));
  } catch (error) {
    logger.error('Error getting chats:', error);
    next(error);
  }
};

/**
 * Get a specific chat by ID
 */
const getChatById = async (req, res, next) => {
  try {
    const { chatId } = req.params;
    const userId = req.user?.id || 'guest';
    
    const chat = await chatService.getChatById(chatId, userId);
    
    if (!chat) {
      return res.status(404).json(formatError('Chat not found', 404));
    }
    
    res.json(formatResponse(true, chat, 'Chat retrieved successfully'));
  } catch (error) {
    logger.error('Error getting chat:', error);
    next(error);
  }
};

/**
 * Create a new chat
 */
const createChat = async (req, res, next) => {
  try {
    const userId = req.user?.id || 'guest';
    const { title, initialMessage } = req.body;
    
    const chat = await chatService.createChat(userId, title, initialMessage);
    
    res.status(201).json(formatResponse(true, chat, 'Chat created successfully'));
  } catch (error) {
    logger.error('Error creating chat:', error);
    next(error);
  }
};

/**
 * Send a message to a chat
 */
const sendMessage = async (req, res, next) => {
  try {
    const { chatId } = req.params;
    const { message } = req.body;
    const userId = req.user?.id || 'guest';
    
    if (!message || message.trim() === '') {
      return res.status(400).json(formatError('Message content is required', 400));
    }
    
    const response = await chatService.sendMessage(chatId, userId, message);
    
    res.json(formatResponse(true, response, 'Message sent successfully'));
  } catch (error) {
    logger.error('Error sending message:', error);
    next(error);
  }
};

/**
 * Delete a chat
 */
const deleteChat = async (req, res, next) => {
  try {
    const { chatId } = req.params;
    const userId = req.user?.id || 'guest';
    
    await chatService.deleteChat(chatId, userId);
    
    res.json(formatResponse(true, null, 'Chat deleted successfully'));
  } catch (error) {
    logger.error('Error deleting chat:', error);
    next(error);
  }
};

/**
 * Clear all chats for a user
 */
const clearChats = async (req, res, next) => {
  try {
    const userId = req.user?.id || 'guest';
    
    await chatService.clearAllChats(userId);
    
    res.json(formatResponse(true, null, 'All chats cleared successfully'));
  } catch (error) {
    logger.error('Error clearing chats:', error);
    next(error);
  }
};

module.exports = {
  getChats,
  getChatById,
  createChat,
  sendMessage,
  deleteChat,
  clearChats
};
