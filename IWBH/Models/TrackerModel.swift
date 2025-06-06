import Foundation
import SwiftUI

struct FightEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let notes: String
    let daysSinceLastFight: Int
}

struct Milestone {
    let days: Int
    let title: String
    let description: String
    let emoji: String
}

class TrackerModel: ObservableObject {
    @Published var daysWithoutFighting: Int = 0
    @Published var lastUpdateDate: Date = Date()
    @Published var fightHistory: [FightEntry] = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    let milestones = [
        Milestone(days: 1, title: "First Day", description: "Starting fresh!", emoji: "🌱"),
        Milestone(days: 3, title: "3 Day Peace", description: "Building momentum", emoji: "🌿"),
        Milestone(days: 7, title: "One Week Strong", description: "A full week of harmony", emoji: "🌳"),
        Milestone(days: 14, title: "Two Weeks", description: "Developing good habits", emoji: "🌲"),
        Milestone(days: 30, title: "One Month", description: "A month of understanding", emoji: "🏆"),
        Milestone(days: 60, title: "Two Months", description: "Incredible progress!", emoji: "🥇"),
        Milestone(days: 90, title: "Three Months", description: "Relationship masters!", emoji: "👑"),
        Milestone(days: 180, title: "Half Year", description: "Six months of peace", emoji: "🎊"),
        Milestone(days: 365, title: "One Year", description: "A full year without fighting!", emoji: "🎉")
    ]
    
    init() {
        loadData()
        updateDaysBasedOnDate()
    }
    
    func updateDaysBasedOnDate() {
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: lastUpdateDate, to: Date()).day ?? 0
        
        if daysDifference > 0 {
            daysWithoutFighting += daysDifference
            currentStreak = daysWithoutFighting
            lastUpdateDate = Date()
            saveData()
        }
    }
    
    func incrementDays() {
        daysWithoutFighting += 1
        currentStreak = daysWithoutFighting
        lastUpdateDate = Date()
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        saveData()
    }
    
    func recordFight(notes: String = "") {
        let fightEntry = FightEntry(
            date: Date(),
            notes: notes,
            daysSinceLastFight: daysWithoutFighting
        )
        fightHistory.append(fightEntry)
        
        if daysWithoutFighting > longestStreak {
            longestStreak = daysWithoutFighting
        }
        
        daysWithoutFighting = 0
        currentStreak = 0
        lastUpdateDate = Date()
        saveData()
    }
    
    func getNextMilestone() -> Milestone? {
        return milestones.first { $0.days > daysWithoutFighting }
    }
    
    func getAchievedMilestones() -> [Milestone] {
        return milestones.filter { $0.days <= daysWithoutFighting }
    }
    
    func getDaysUntilNextMilestone() -> Int {
        guard let nextMilestone = getNextMilestone() else { return 0 }
        return nextMilestone.days - daysWithoutFighting
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(daysWithoutFighting, forKey: "daysWithoutFighting")
        defaults.set(lastUpdateDate, forKey: "lastUpdateDate")
        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(longestStreak, forKey: "longestStreak")
        
        if let encoded = try? JSONEncoder().encode(fightHistory) {
            defaults.set(encoded, forKey: "fightHistory")
        }
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        daysWithoutFighting = defaults.integer(forKey: "daysWithoutFighting")
        lastUpdateDate = defaults.object(forKey: "lastUpdateDate") as? Date ?? Date()
        currentStreak = defaults.integer(forKey: "currentStreak")
        longestStreak = defaults.integer(forKey: "longestStreak")
        
        if let data = defaults.data(forKey: "fightHistory"),
           let decoded = try? JSONDecoder().decode([FightEntry].self, from: data) {
            fightHistory = decoded
        }
    }
}
