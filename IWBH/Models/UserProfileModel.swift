import Foundation
import SwiftUI

@MainActor
struct UserProfile: Identifiable, Codable, Equatable {
    var id = UUID()
    var userID: String
    var name: String
    var displayName: String
    var profileEmoji: String
    var bio: String
    var loveLanguage: LoveLanguage?
    var interests: [String]
    var dateCreated: Date
    var pairCode: String?
    var partnerId: String?
    var isOnline: Bool
    var lastSeen: Date

    // Local-only, not persisted to Firebase
    var partnerProfile: PartnerInfo?

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

    nonisolated static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        lhs.id == rhs.id &&
        lhs.userID == rhs.userID &&
        lhs.name == rhs.name &&
        lhs.displayName == rhs.displayName &&
        lhs.profileEmoji == rhs.profileEmoji &&
        lhs.bio == rhs.bio &&
        lhs.loveLanguage == rhs.loveLanguage &&
        lhs.interests == rhs.interests &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.pairCode == rhs.pairCode &&
        lhs.partnerId == rhs.partnerId &&
        lhs.isOnline == rhs.isOnline &&
        lhs.lastSeen == rhs.lastSeen &&
        lhs.partnerProfile == rhs.partnerProfile
    }

    enum CodingKeys: String, CodingKey {
        case userID, name, displayName, profileEmoji, bio, loveLanguage, interests, dateCreated, pairCode, partnerId, isOnline, lastSeen
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

struct PartnerInfo: Codable, Equatable {
    var userID: String
    var name: String
    var displayName: String
    var profileEmoji: String
    var bio: String
    var isOnline: Bool
    var lastSeen: Date

    init(from profile: UserProfile) {
        self.userID = profile.userID
        self.name = profile.name
        self.displayName = profile.displayName
        self.profileEmoji = profile.profileEmoji
        self.bio = profile.bio
        self.isOnline = profile.isOnline
        self.lastSeen = profile.lastSeen
    }

    // Add this explicit initializer
    init(userID: String, name: String, displayName: String, profileEmoji: String, bio: String, isOnline: Bool, lastSeen: Date) {
        self.userID = userID
        self.name = name
        self.displayName = displayName
        self.profileEmoji = profileEmoji
        self.bio = bio
        self.isOnline = isOnline
        self.lastSeen = lastSeen
    }
}


enum PairingStatus: Codable {
    case unpaired
    case waitingForPartner
    case paired
    case pairingFailed
}
extension UserProfile {
    static let fallback = UserProfile(userID: "unknown", name: "Unknown")
}

