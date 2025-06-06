import Foundation
import WidgetKit

struct WidgetTracker: Codable {
    let name: String
    let emoji: String
    let color: String
    let trackingType: String
    let unit: String
    let currentValue: Int
    let isPrimary: Bool
}

struct TrackerWidgetEntry: TimelineEntry {
    let date: Date
    let tracker: WidgetTracker?
}
private func createEntry(for date: Date = Date()) -> TrackerWidgetEntry {
    let defaults = UserDefaults(suiteName: "group.leeCorp.IWBH")
    var tracker: WidgetTracker? = nil

    if let data = defaults?.data(forKey: "customTrackers"),
       let decoded = try? JSONDecoder().decode([CustomTracker].self, from: data),
       let primary = decoded.first(where: { $0.isPrimary }) {
        tracker = WidgetTracker(
            name: primary.name,
            emoji: primary.emoji,
            color: primary.color,
            trackingType: primary.trackingType.rawValue,
            unit: primary.unit,
            currentValue: calculateCurrentValue(for: primary, on: date),
            isPrimary: primary.isPrimary
        )
    }

    return TrackerWidgetEntry(date: date, tracker: tracker)
}

private func calculateCurrentValue(for tracker: CustomTracker, on date: Date) -> Int {
    let calendar = Calendar.current
    let daysSinceUpdate = calendar.dateComponents([.day], from: tracker.lastUpdated, to: date).day ?? 0
    return tracker.currentValue + daysSinceUpdate
}
