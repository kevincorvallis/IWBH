const { v4: uuidv4 } = require('uuid');

class User {
  constructor(data = {}) {
    this.id = data.id || uuidv4();
    this.email = data.email;
    this.appleId = data.appleId; // For Apple Sign In
    this.displayName = data.displayName;
    this.profileData = data.profileData || {};
    this.preferences = data.preferences || {};
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
    this.lastLoginAt = data.lastLoginAt;
    this.isActive = data.isActive !== undefined ? data.isActive : true;
    this.isGuest = data.isGuest || false;
  }

  updateProfile(profileData) {
    this.profileData = { ...this.profileData, ...profileData };
    this.updatedAt = new Date().toISOString();
  }

  updatePreferences(preferences) {
    this.preferences = { ...this.preferences, ...preferences };
    this.updatedAt = new Date().toISOString();
  }

  updateLastLogin() {
    this.lastLoginAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      email: this.email,
      appleId: this.appleId,
      displayName: this.displayName,
      profileData: this.profileData,
      preferences: this.preferences,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      lastLoginAt: this.lastLoginAt,
      isActive: this.isActive,
      isGuest: this.isGuest
    };
  }

  toPublicJSON() {
    return {
      id: this.id,
      displayName: this.displayName,
      profileData: this.profileData,
      isGuest: this.isGuest
    };
  }

  static fromDynamoDB(item) {
    return new User({
      id: item.id,
      email: item.email,
      appleId: item.appleId,
      displayName: item.displayName,
      profileData: item.profileData || {},
      preferences: item.preferences || {},
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      lastLoginAt: item.lastLoginAt,
      isActive: item.isActive,
      isGuest: item.isGuest
    });
  }
}

module.exports = User;
