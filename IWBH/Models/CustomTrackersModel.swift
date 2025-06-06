import Foundation
import SwiftUI

struct CustomTracker: Identifiable, Codable {
    var id: UUID
    var name: String
    var emoji: String
    var color: String // Color name as string
    var trackingType: TrackingType
    var currentValue: Int
    var goal: Int?
    var unit: String // "days", "times", "hours", etc.
    var isActive: Bool
    var dateCreated: Date
    var lastUpdated: Date
    var history: [TrackerEntry]
    var longestStreak: Int
    var currentStreak: Int
    var isPrimary: Bool
    
    init(name: String, emoji: String, color: String, trackingType: TrackingType, unit: String, goal: Int? = nil, isTemplate: Bool = false) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.color = color
        self.trackingType = trackingType
        self.currentValue = 0
        self.goal = goal
        self.unit = unit
        self.isActive = true
        self.dateCreated = Date()
        self.lastUpdated = Date()
        self.history = []
        self.longestStreak = 0
        self.currentStreak = 0
        self.isPrimary = false
    }
}

enum TrackingType: String, CaseIterable, Codable {
    case streak = "streak"           // Days without/with something
    case counter = "counter"         // Count of actions
    case timer = "timer"            // Time-based tracking
    case negativeEvent = "negative_event"  // Track days since negative event (like fights, bringing up exes, etc)
    
    var description: String {
        switch self {
        case .streak:
            return "Track consecutive days"
        case .counter:
            return "Count occurrences"
        case .timer:
            return "Track time spent"
        case .negativeEvent:
            return "Days since last incident"
        }
    }
    
    var isNegativeTracking: Bool {
        return self == .negativeEvent || self == .streak
    }
}

struct TrackerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    let value: Int
    let notes: String?
    let type: EntryType
    
    init(date: Date = Date(), value: Int, notes: String? = nil, type: EntryType) {
        self.id = UUID()
        self.date = date
        self.value = value
        self.notes = notes
        self.type = type
    }
    
    enum EntryType: String, Codable {
        case increment = "increment"
        case reset = "reset"
        case manual = "manual"
        case negativeEvent = "negative_event"
    }
}

struct TrackerTemplate {
    let name: String
    let emoji: String
    let color: String
    let trackingType: TrackingType
    let unit: String
    let goal: Int?
    let description: String
    
    static let predefined: [TrackerTemplate] = [
        // Relationship Trackers
        TrackerTemplate(name: "Days Without Fighting", emoji: "💕", color: "pink", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track peaceful days in your relationship"),
        TrackerTemplate(name: "Days Since Bringing Up Ex", emoji: "😤", color: "red", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track days since mentioning past relationships"),
        TrackerTemplate(name: "Days Without Arguing About Money", emoji: "💰", color: "yellow", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track days without financial disagreements"),
        TrackerTemplate(name: "Days Since Being Late", emoji: "⏰", color: "orange", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track punctuality in the relationship"),
        TrackerTemplate(name: "Days Without Phone During Dinner", emoji: "📱", color: "red", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track distraction-free meal times"),
        TrackerTemplate(name: "Days Since Forgetting Anniversary", emoji: "📅", color: "purple", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track special date remembrance"),
        TrackerTemplate(name: "Days Without Jealousy Issues", emoji: "💚", color: "green", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track trust and security in relationship"),
        TrackerTemplate(name: "Days Since Canceling Plans", emoji: "❌", color: "red", trackingType: .negativeEvent, unit: "days", goal: nil, description: "Track commitment to shared activities"),
        
        // Positive Relationship Trackers
        TrackerTemplate(name: "Date Nights", emoji: "💑", color: "pink", trackingType: .counter, unit: "dates", goal: 12, description: "Quality time with partner"),
        TrackerTemplate(name: "Acts of Kindness", emoji: "🤝", color: "green", trackingType: .counter, unit: "acts", goal: 100, description: "Count kind gestures you do"),
        TrackerTemplate(name: "Compliments Given", emoji: "😍", color: "yellow", trackingType: .counter, unit: "compliments", goal: 50, description: "Track positive affirmations"),
        TrackerTemplate(name: "Surprise Gestures", emoji: "🎁", color: "purple", trackingType: .counter, unit: "surprises", goal: 20, description: "Small unexpected acts of love"),
        
        // Personal Growth Trackers
        TrackerTemplate(name: "Exercise Days", emoji: "💪", color: "blue", trackingType: .streak, unit: "days", goal: 30, description: "Track consecutive workout days"),
        TrackerTemplate(name: "Meditation Streak", emoji: "🧘‍♀️", color: "purple", trackingType: .streak, unit: "days", goal: 21, description: "Daily meditation practice"),
        TrackerTemplate(name: "Reading Time", emoji: "📚", color: "orange", trackingType: .timer, unit: "minutes", goal: 1800, description: "Track daily reading time"),
        TrackerTemplate(name: "Water Intake", emoji: "💧", color: "blue", trackingType: .counter, unit: "glasses", goal: 8, description: "Daily water consumption"),
        TrackerTemplate(name: "Gratitude Days", emoji: "🙏", color: "yellow", trackingType: .streak, unit: "days", goal: 30, description: "Days practicing gratitude"),
        TrackerTemplate(name: "Creative Work", emoji: "🎨", color: "red", trackingType: .timer, unit: "hours", goal: 40, description: "Time spent on creative projects"),
        TrackerTemplate(name: "Learning Streak", emoji: "🎓", color: "indigo", trackingType: .streak, unit: "days", goal: 60, description: "Continuous learning days")
    ]
}

class CustomTrackersModel: ObservableObject {
    @Published var trackers: [CustomTracker] = []
    @Published var activeTrackers: [CustomTracker] = []
    
    init() {
        loadTrackers()
        updateActiveTrackers()
        updateStreaksBasedOnDate()
    }
    
    // MARK: - Tracker Management
    
    func addTracker(_ tracker: CustomTracker) {
        trackers.append(tracker)
        saveTrackers()
        updateActiveTrackers()
    }
    
    func addTracker(from template: TrackerTemplate) {
        let tracker = CustomTracker(
            name: template.name,
            emoji: template.emoji,
            color: template.color,
            trackingType: template.trackingType,
            unit: template.unit,
            goal: template.goal
        )
        addTracker(tracker)
    }
    
    func updateTracker(_ tracker: CustomTracker) {
        if let index = trackers.firstIndex(where: { $0.id == tracker.id }) {
            trackers[index] = tracker
            saveTrackers()
            updateActiveTrackers()
        }
    }
    
    func deleteTracker(_ tracker: CustomTracker) {
        trackers.removeAll { $0.id == tracker.id }
        saveTrackers()
        updateActiveTrackers()
    }
    
    func toggleTrackerActive(_ tracker: CustomTracker) {
        if let index = trackers.firstIndex(where: { $0.id == tracker.id }) {
            trackers[index].isActive.toggle()
            saveTrackers()
            updateActiveTrackers()
        }
    }
    
    // MARK: - Tracking Actions
    
    func incrementTracker(_ trackerId: UUID, by value: Int = 1, notes: String? = nil) {
        guard let index = trackers.firstIndex(where: { $0.id == trackerId }) else { return }
        
        if trackers[index].trackingType == .negativeEvent {
            // For negative events, "incrementing" means the negative event happened, so reset to 0
            recordNegativeEvent(trackerId, notes: notes)
        } else {
            // Normal increment for positive trackers
            let entry = TrackerEntry(
                date: Date(),
                value: value,
                notes: notes,
                type: .increment
            )
            
            trackers[index].currentValue += value
            trackers[index].lastUpdated = Date()
            trackers[index].history.append(entry)
            
            // Update streaks for streak-type trackers
            if trackers[index].trackingType == .streak {
                trackers[index].currentStreak += value
                if trackers[index].currentStreak > trackers[index].longestStreak {
                    trackers[index].longestStreak = trackers[index].currentStreak
                }
            }
            
            saveTrackers()
            updateActiveTrackers()
        }
    }
    
    func recordNegativeEvent(_ trackerId: UUID, notes: String? = nil) {
        guard let index = trackers.firstIndex(where: { $0.id == trackerId }) else { return }
        
        let entry = TrackerEntry(
            date: Date(),
            value: trackers[index].currentValue,
            notes: notes,
            type: .negativeEvent
        )
        
        // Update longest streak before reset
        if trackers[index].currentValue > trackers[index].longestStreak {
            trackers[index].longestStreak = trackers[index].currentValue
        }
        
        trackers[index].history.append(entry)
        trackers[index].currentValue = 0
        trackers[index].currentStreak = 0
        trackers[index].lastUpdated = Date()
        
        saveTrackers()
        updateActiveTrackers()
    }
    
    func resetTracker(_ trackerId: UUID, notes: String? = nil) {
        guard let index = trackers.firstIndex(where: { $0.id == trackerId }) else { return }
        
        let entry = TrackerEntry(
            date: Date(),
            value: trackers[index].currentValue,
            notes: notes,
            type: .reset
        )
        
        // Update longest streak before reset
        if trackers[index].currentStreak > trackers[index].longestStreak {
            trackers[index].longestStreak = trackers[index].currentStreak
        }
        
        trackers[index].history.append(entry)
        trackers[index].currentValue = 0
        trackers[index].currentStreak = 0
        trackers[index].lastUpdated = Date()
        
        saveTrackers()
        updateActiveTrackers()
    }
    
    func setTrackerValue(_ trackerId: UUID, value: Int, notes: String? = nil) {
        guard let index = trackers.firstIndex(where: { $0.id == trackerId }) else { return }
        
        let entry = TrackerEntry(
            date: Date(),
            value: value,
            notes: notes,
            type: .manual
        )
        
        trackers[index].currentValue = value
        trackers[index].lastUpdated = Date()
        trackers[index].history.append(entry)
        
        saveTrackers()
        updateActiveTrackers()
    }
    
    // MARK: - Date-based Updates
    
    func updateStreaksBasedOnDate() {
        let calendar = Calendar.current
        
        for index in trackers.indices {
            guard trackers[index].trackingType == .streak || trackers[index].trackingType == .negativeEvent else { continue }
            
            let daysDifference = calendar.dateComponents([.day], from: trackers[index].lastUpdated, to: Date()).day ?? 0
            
            if daysDifference > 0 {
                if trackers[index].trackingType == .negativeEvent {
                    // For negative events, each day that passes increases the "days since" counter
                    trackers[index].currentValue += daysDifference
                    trackers[index].currentStreak += daysDifference
                } else if trackers[index].trackingType == .streak {
                    // For positive streaks (like exercise), add the days only if it's a "without" tracker
                    if trackers[index].name.lowercased().contains("without") {
                        trackers[index].currentValue += daysDifference
                        trackers[index].currentStreak += daysDifference
                    }
                }
                
                trackers[index].lastUpdated = Date()
            }
        }
        
        saveTrackers()
        updateActiveTrackers()
    }
    
    // MARK: - Helper Methods
    
    private func updateActiveTrackers() {
        activeTrackers = trackers.filter { $0.isActive }
    }
    
    func getGoalProgress(_ tracker: CustomTracker) -> Double {
        guard let goal = tracker.goal else { return 0 }
        return min(Double(tracker.currentValue) / Double(goal), 1.0)
    }
    
    func getGoalProgressText(_ tracker: CustomTracker) -> String {
        guard let goal = tracker.goal else { return "" }
        return "\(tracker.currentValue) / \(goal) \(tracker.unit)"
    }
    
    func getTrackerColor(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "indigo": return .indigo
        case "teal": return .teal
        case "mint": return .mint
        default: return .blue
        }
    }
    
    // MARK: - Persistence
    
    private func saveTrackers() {
        if let encoded = try? JSONEncoder().encode(trackers) {
            UserDefaults.standard.set(encoded, forKey: "customTrackers")
        }
    }
    
    func loadTrackers() {
        if let data = UserDefaults.standard.data(forKey: "customTrackers"),
           let decoded = try? JSONDecoder().decode([CustomTracker].self, from: data) {
            trackers = decoded
        } else {
            // Create default "Days Without Fighting" tracker for existing users
            let defaultTracker = CustomTracker(
                name: "Days Without Fighting",
                emoji: "💕",
                color: "pink",
                trackingType: .streak,
                unit: "days"
            )
            trackers = [defaultTracker]
        }
    }
    
    // MARK: - Convenience Methods for Views
    
    func getCurrentValue(for tracker: CustomTracker, on date: Date = Date()) -> Int {
        // For date-based trackers, calculate days since last update
        if tracker.trackingType == .negativeEvent || (tracker.trackingType == .streak && tracker.name.lowercased().contains("without")) {
            let calendar = Calendar.current
            let daysSinceUpdate = calendar.dateComponents([.day], from: tracker.lastUpdated, to: date).day ?? 0
            return tracker.currentValue + daysSinceUpdate
        }
        return tracker.currentValue
    }
    
    func incrementTracker(_ tracker: CustomTracker, by value: Int = 1, notes: String? = nil) {
        incrementTracker(tracker.id, by: value, notes: notes)
    }
    
    func recordNegativeEvent(for tracker: CustomTracker, notes: String? = nil) {
        recordNegativeEvent(tracker.id, notes: notes)
    }
    
    func resetTracker(_ tracker: CustomTracker, notes: String? = nil) {
        resetTracker(tracker.id, notes: notes)
    }
    
    func setTrackerValue(_ tracker: CustomTracker, value: Int, notes: String? = nil) {
        setTrackerValue(tracker.id, value: value, notes: notes)
    }
}
