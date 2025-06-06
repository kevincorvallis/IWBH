import WidgetKit
import SwiftUI

// Simple data structures for widget (avoiding complex model dependencies)
struct WidgetTracker {
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

struct TrackerWidget: Widget {
    let kind: String = "TrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrackerTimelineProvider()) { entry in
            TrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Relationship Tracker")
        .description("Track your relationship goals and milestones.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TrackerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrackerWidgetEntry {
        TrackerWidgetEntry(
            date: Date(),
            tracker: WidgetTracker(
                name: "Days Without Fighting",
                emoji: "❤️",
                color: "red",
                trackingType: "negativeEvent",
                unit: "days",
                currentValue: 5,
                isPrimary: true
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TrackerWidgetEntry) -> ()) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrackerWidgetEntry>) -> ()) {
        var entries: [TrackerWidgetEntry] = []
        let currentDate = Date()
        
        // Create timeline entries for the next 24 hours, updating every hour
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = createEntry(for: entryDate)
            entries.append(entry)
        }

        // Create a timeline with policy to refresh after entries
        let timeline = Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .hour, value: 24, to: currentDate)!))
        completion(timeline)
    }
    
    private func createEntry(for date: Date = Date()) -> TrackerWidgetEntry {
        // In a real implementation, this would load from shared UserDefaults or Core Data
        // For now, return a placeholder
        let tracker = WidgetTracker(
            name: "Days Without Fighting",
            emoji: "❤️",
            color: "red",
            trackingType: "negativeEvent",
            unit: "days",
            currentValue: calculateDaysSince(date),
            isPrimary: true
        )
        
        return TrackerWidgetEntry(
            date: date,
            tracker: tracker
        )
    }
    
    private func calculateDaysSince(_ date: Date) -> Int {
        // This would normally read from shared data
        // For now, return a calculated value
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfGivenDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: startOfGivenDate, to: startOfToday).day ?? 0
    }
}

struct TrackerWidgetView: View {
    var entry: TrackerWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let tracker = entry.tracker {
            VStack(spacing: 8) {
                if family != .systemSmall {
                    HStack {
                        Text(tracker.emoji)
                            .font(.title2)
                        
                        Text(tracker.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
                
                HStack {
                    if family == .systemSmall {
                        Text(tracker.emoji)
                            .font(.title)
                    }
                    
                    VStack(alignment: family == .systemSmall ? .center : .leading, spacing: 2) {
                        Text("\(tracker.currentValue)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(getColor(from: tracker.color))
                        
                        Text(tracker.unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if family == .systemSmall {
                            Text(tracker.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    
                    if family != .systemSmall {
                        Spacer()
                    }
                }
                
                if family == .systemLarge {
                    Spacer()
                    
                    HStack {
                        Text("Last updated")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(entry.date, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(getColor(from: tracker.color).opacity(0.1))
            )
        } else {
            VStack {
                Image(systemName: "heart.slash")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                
                Text("No Trackers")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Create a tracker in the app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    private func getColor(from colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }
}