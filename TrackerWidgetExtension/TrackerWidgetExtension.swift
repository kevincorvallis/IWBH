//
//  TrackerWidgetExtension.swift
//  TrackerWidgetExtension
//
//  Created by Kevin Lee on 6/8/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), trackerName: "Days Without Fighting", trackerValue: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = createEntry(for: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func createEntry(for date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.leeCorp.IWBH")
        let trackerName = "Days Without Fighting"
        let startDate = defaults?.object(forKey: "trackerStartDate") as? Date ?? Date()
        let daysElapsed = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0

        return SimpleEntry(date: date, trackerName: trackerName, trackerValue: daysElapsed)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let trackerName: String
    let trackerValue: Int
}

// Further refined widget design for .systemSmall to prevent text cutoff
struct TrackerWidgetExtensionEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .center, spacing: 0) { // Centered for systemSmall
            if family == .systemSmall {
                Text("🌟")
                    .font(.title)
                    .padding(.top, 4)
                Text(entry.trackerName)
                    .font(.caption2) // Smaller font for tracker name
                    .lineLimit(1)    // Limit to 1 line for small size
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                Text("\(entry.trackerValue)")
                    .font(.system(size: 30, weight: .bold)) // Prominent number
                    .foregroundColor(Color.blue)
                Text("days")
                    .font(.system(size: 10)) // Very small "days" label
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            } else {
                // Existing layout for medium and large sizes
                HStack {
                    Text("🌟")
                        .font(.title)
                        .padding(.trailing, 4)
                    Text(entry.trackerName)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding([.top, .leading, .trailing])

                Spacer()

                Text("\(entry.trackerValue)")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(Color.blue)
                    .padding([.leading, .trailing])

                Text("days")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing, .bottom])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack fills the space
        .containerBackground(for: .widget) {
            // Standard container background
        }
    }
}

struct TrackerWidgetExtension: Widget {
    let kind: String = "TrackerWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TrackerWidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Tracker Widget")
        .description("Displays the number of days for your tracker.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TrackerWidgetExtensionEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerWidgetExtensionEntryView(entry: SimpleEntry(date: .now, trackerName: "Days Without Fighting", trackerValue: 5))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
