//
//  TrackerWidgetExtensionLiveActivity.swift
//  TrackerWidgetExtension
//
//  Created by Kevin Lee on 6/8/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TrackerWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TrackerWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrackerWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TrackerWidgetExtensionAttributes {
    fileprivate static var preview: TrackerWidgetExtensionAttributes {
        TrackerWidgetExtensionAttributes(name: "World")
    }
}

extension TrackerWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: TrackerWidgetExtensionAttributes.ContentState {
        TrackerWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TrackerWidgetExtensionAttributes.ContentState {
         TrackerWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TrackerWidgetExtensionAttributes.preview) {
   TrackerWidgetExtensionLiveActivity()
} contentStates: {
    TrackerWidgetExtensionAttributes.ContentState.smiley
    TrackerWidgetExtensionAttributes.ContentState.starEyes
}
