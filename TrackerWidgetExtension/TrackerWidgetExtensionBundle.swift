//
//  TrackerWidgetExtensionBundle.swift
//  TrackerWidgetExtension
//
//  Created by Kevin Lee on 6/8/25.
//

import WidgetKit
import SwiftUI

@main
struct TrackerWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        TrackerWidgetExtension()
        TrackerWidgetExtensionControl()
        TrackerWidgetExtensionLiveActivity()
    }
}
