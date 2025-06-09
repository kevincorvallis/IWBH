import SwiftUI

struct TrackersView: View {
    @EnvironmentObject private var trackersModel: CustomTrackersModel
    @State private var showingAddTracker = false
    @State private var showingTracker: CustomTracker?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if trackersModel.activeTrackers.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(trackersModel.activeTrackers) { tracker in
                            TrackerCard(
                                tracker: tracker,
                                onIncrement: { trackersModel.incrementTracker(tracker.id) },
                                onReset: { trackersModel.resetTracker(tracker.id) },
                                onTap: { showingTracker = tracker }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Space for floating button
            }
            .navigationTitle("Trackers")
            .navigationBarItems(
                trailing: Button(action: { showingAddTracker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            )
        }
        .sheet(isPresented: $showingAddTracker) {
            AddTrackerView(trackersModel: trackersModel)
        }
        .sheet(item: $showingTracker) { tracker in
            TrackerDetailView(tracker: tracker, trackersModel: trackersModel)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("📊")
                    .font(.system(size: 60))
                
                Text("No Trackers Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first tracker to start building positive habits and monitoring your progress.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { showingAddTracker = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Tracker")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
            }
            .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }
}

struct TrackerCard: View {
    let tracker: CustomTracker
    let onIncrement: () -> Void
    let onReset: () -> Void
    let onTap: () -> Void
    
    @StateObject private var trackersModel = CustomTrackersModel()
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(tracker.emoji)
                                .font(.title2)
                            Text(tracker.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        if tracker.trackingType == .streak {
                            Text("Current Streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(tracker.currentValue)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(trackersModel.getTrackerColor(tracker.color))
                        
                        Text(tracker.unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress bar (if goal is set)
                if tracker.goal != nil {
                    VStack(spacing: 8) {
                        ProgressView(value: trackersModel.getGoalProgress(tracker))
                            .progressViewStyle(LinearProgressViewStyle(tint: trackersModel.getTrackerColor(tracker.color)))
                        
                        HStack {
                            Text(trackersModel.getGoalProgressText(tracker))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            let percentage = Int(trackersModel.getGoalProgress(tracker) * 100)
                            Text("\(percentage)%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(trackersModel.getTrackerColor(tracker.color))
                        }
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onIncrement) {
                        HStack {
                            if tracker.trackingType == .negativeEvent {
                                Image(systemName: "exclamationmark.circle.fill")
                            } else {
                                Image(systemName: "plus.circle.fill")
                            }
                            Text(getIncrementText())
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(tracker.trackingType == .negativeEvent ? Color.red : trackersModel.getTrackerColor(tracker.color))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if tracker.trackingType == .streak || tracker.trackingType == .negativeEvent {
                        Button(action: onReset) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIncrementText() -> String {
        switch tracker.trackingType {
        case .streak:
            return "+1 Day"
        case .counter:
            return "+1"
        case .timer:
            return "+1 \(tracker.unit.capitalized)"
        case .negativeEvent:
            return "Record Event"
        }
    }
}

struct AddTrackerView: View {
    let trackersModel: CustomTrackersModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTemplate: TrackerTemplate?
    @State private var showingCustomForm = false
    @State private var searchText = ""
    
    var filteredTemplates: [TrackerTemplate] {
        if searchText.isEmpty {
            return TrackerTemplate.predefined
        } else {
            return TrackerTemplate.predefined.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Custom tracker option
                        Button(action: { showingCustomForm = true }) {
                            HStack {
                                VStack {
                                    Text("🎯")
                                        .font(.title2)
                                    Text("Custom")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .frame(width: 60)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Create Custom Tracker")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Design your own tracker with custom settings")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Predefined templates
                        ForEach(filteredTemplates, id: \.name) { template in
                            TrackerTemplateRow(
                                template: template,
                                onSelect: {
                                    trackersModel.addTracker(from: template)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Add Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
        .sheet(isPresented: $showingCustomForm) {
            CustomTrackerFormView(trackersModel: trackersModel)
        }
    }
}

struct TrackerTemplateRow: View {
    let template: TrackerTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack {
                    Text(template.emoji)
                        .font(.title2)
                    
                    Circle()
                        .fill(getColor(template.color))
                        .frame(width: 8, height: 8)
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(template.trackingType.rawValue.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                        
                        if let goal = template.goal {
                            Text("Goal: \(goal) \(template.unit)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(getColor(template.color).opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundColor(getColor(template.color))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getColor(_ colorName: String) -> Color {
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
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search trackers...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct TrackersView_Previews: PreviewProvider {
    static var previews: some View {
        TrackersView()
    }
}
