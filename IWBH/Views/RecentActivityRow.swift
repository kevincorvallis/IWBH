//
//  RecentActivityRow.swift
//  IWBH
//
//  Created by Kevin Lee on 6/5/25.
//


import SwiftUI

struct RecentActivityRow: View {
    let tracker: CustomTracker
    let model: CustomTrackersModel
    
    var body: some View {
        HStack(spacing: 12) {
            Text(tracker.emoji)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tracker.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Current: \(model.getCurrentValue(for: tracker)) \(tracker.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(model.getCurrentValue(for: tracker), format: .number)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(tracker.color))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
}
