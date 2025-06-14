const { v4: uuidv4 } = require('uuid');

class Chat {
  constructor(data = {}) {
    this.id = data.id || uuidv4();
    this.userId = data.userId;
    this.title = data.title || 'New Chat';
    this.messages = data.messages || [];
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
    this.isActive = data.isActive !== undefined ? data.isActive : true;
    this.metadata = data.metadata || {};
  }

  addMessage(role, content, metadata = {}) {
    const message = {
      id: uuidv4(),
      role, // 'user' or 'assistant'
      content,
      timestamp: new Date().toISOString(),
      metadata
    };
    
    this.messages.push(message);
    this.updatedAt = new Date().toISOString();
    
    return message;
  }

  updateTitle(newTitle) {
    this.title = newTitle;
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      userId: this.userId,
      title: this.title,
      messages: this.messages,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      isActive: this.isActive,
      metadata: this.metadata
    };
  }

  static fromDynamoDB(item) {
    return new Chat({
      id: item.id,
      userId: item.userId,
      title: item.title,
      messages: item.messages || [],
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      isActive: item.isActive,
      metadata: item.metadata || {}
    });
  }
}

module.exports = Chat;
