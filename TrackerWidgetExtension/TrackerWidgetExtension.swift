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

// Adopt the containerBackground API for the widget view
struct TrackerWidgetExtensionEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.trackerName)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("\(entry.trackerValue) days")
                .font(.largeTitle)
                .bold()
        }
        .padding()
        .containerBackground(.thinMaterial, for: .widget) // Corrected containerBackground API call
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
