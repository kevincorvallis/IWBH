import WidgetKit
import SwiftUI
import Foundation

// MARK: - WidgetTracker, TrackerWidgetEntry, createEntry, calculateCurrentValue
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

struct TrackerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrackerWidgetEntry {
        // Return an empty entry (no placeholder data)
        TrackerWidgetEntry(date: Date(), tracker: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TrackerWidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrackerWidgetEntry>) -> Void) {
        let entry = createEntry()
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TrackerWidgetView: View {
    var entry: TrackerWidgetEntry

    var body: some View {
        if let tracker = entry.tracker {
            ZStack {
                colorFromHex(tracker.color)
                VStack(alignment: .center, spacing: 8) {
                    Text(tracker.emoji)
                        .font(.system(size: 40))
                    Text(tracker.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 4) {
                        Text("\(tracker.currentValue)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        Text(tracker.unit)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
            }
        } else {
            Color.gray.opacity(0.2)
            VStack {
                Text("No Primary Tracker")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }

    func colorFromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}

struct TrackerWidget: Widget {
    let kind: String = "TrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrackerWidgetProvider()) { entry in
            TrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Primary Tracker")
        .description("Shows your primary tracker at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
