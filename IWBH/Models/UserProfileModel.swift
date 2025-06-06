import Foundation
import SwiftUI

struct UserProfile: Identifiable, Codable {
    var id = UUID()
    var userID: String // From authentication
    var name: String
    var displayName: String
    var profileEmoji: String
    var bio: String
    var loveLanguage: LoveLanguage?
    var interests: [String]
    var dateCreated: Date
    var pairCode: String? // Unique 6-digit code for pairing
    var partnerId: String? // Partner's userID when paired
    var partnerProfile: PartnerInfo? // Cached partner info
    var isOnline: Bool
    var lastSeen: Date
    
    // Custom Codable implementation to handle UUID id
    enum CodingKeys: String, CodingKey {
        case id, userID, name, displayName, profileEmoji, bio, loveLanguage, interests, dateCreated, pairCode, partnerId, partnerProfile, isOnline, lastSeen
    }
    
    init(userID: String, name: String) {
        self.userID = userID
        self.name = name
        self.displayName = name
        self.profileEmoji = ["💝", "💕", "💖", "💗", "💓", "💞", "💘", "❤️", "🧡", "💛", "💚", "💙", "💜", "🤍", "🖤", "🤎"].randomElement() ?? "💝"
        self.bio = ""
        self.interests = []
        self.dateCreated = Date()
        self.isOnline = true
        self.lastSeen = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userID = try container.decode(String.self, forKey: .userID)
        name = try container.decode(String.self, forKey: .name)
        displayName = try container.decode(String.self, forKey: .displayName)
        profileEmoji = try container.decode(String.self, forKey: .profileEmoji)
        bio = try container.decode(String.self, forKey: .bio)
        loveLanguage = try container.decodeIfPresent(LoveLanguage.self, forKey: .loveLanguage)
        interests = try container.decode([String].self, forKey: .interests)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        pairCode = try container.decodeIfPresent(String.self, forKey: .pairCode)
        partnerId = try container.decodeIfPresent(String.self, forKey: .partnerId)
        partnerProfile = try container.decodeIfPresent(PartnerInfo.self, forKey: .partnerProfile)
        isOnline = try container.decode(Bool.self, forKey: .isOnline)
        lastSeen = try container.decode(Date.self, forKey: .lastSeen)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userID, forKey: .userID)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(profileEmoji, forKey: .profileEmoji)
        try container.encode(bio, forKey: .bio)
        try container.encodeIfPresent(loveLanguage, forKey: .loveLanguage)
        try container.encode(interests, forKey: .interests)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(pairCode, forKey: .pairCode)
        try container.encodeIfPresent(partnerId, forKey: .partnerId)
        try container.encodeIfPresent(partnerProfile, forKey: .partnerProfile)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(lastSeen, forKey: .lastSeen)
    }
}

struct PartnerInfo: Codable {
    var userID: String
    var name: String
    var displayName: String
    var profileEmoji: String
    var bio: String
    var isOnline: Bool
    var lastSeen: Date
    
    init(userID: String, name: String, displayName: String, profileEmoji: String, bio: String, isOnline: Bool, lastSeen: Date) {
        self.userID = userID
        self.name = name
        self.displayName = displayName
        self.profileEmoji = profileEmoji
        self.bio = bio
        self.isOnline = isOnline
        self.lastSeen = lastSeen
    }
    
    init(from profile: UserProfile) {
        self.userID = profile.userID
        self.name = profile.name
        self.displayName = profile.displayName
        self.profileEmoji = profile.profileEmoji
        self.bio = profile.bio
        self.isOnline = profile.isOnline
        self.lastSeen = profile.lastSeen
    }
}

enum LoveLanguage: String, CaseIterable, Codable {
    case wordsOfAffirmation = "Words of Affirmation"
    case physicalTouch = "Physical Touch"
    case qualityTime = "Quality Time"
    case actsOfService = "Acts of Service"
    case receivingGifts = "Receiving Gifts"
    
    var emoji: String {
        switch self {
        case .wordsOfAffirmation: return "💬"
        case .physicalTouch: return "🤗"
        case .qualityTime: return "⏰"
        case .actsOfService: return "🤝"
        case .receivingGifts: return "🎁"
        }
    }
    
    var description: String {
        switch self {
        case .wordsOfAffirmation: return "You feel loved through kind words and encouragement"
        case .physicalTouch: return "You feel loved through hugs, cuddles, and physical closeness"
        case .qualityTime: return "You feel loved through undivided attention and meaningful time together"
        case .actsOfService: return "You feel loved when your partner helps and supports you"
        case .receivingGifts: return "You feel loved through thoughtful gifts and gestures"
        }
    }
}

enum PairingStatus: Codable {
    case unpaired
    case waitingForPartner
    case paired
    case pairingFailed
}
