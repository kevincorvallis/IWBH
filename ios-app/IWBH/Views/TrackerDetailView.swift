import SwiftUI

struct TrackerDetailView: View {
    let tracker: CustomTracker
    let trackersModel: CustomTrackersModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingResetAlert = false
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 20) {
                        HStack {
                            Text(tracker.emoji)
                                .font(.system(size: 50))
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(tracker.currentValue)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(trackersModel.getTrackerColor(tracker.color))
                                
                                Text(tracker.unit)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text(tracker.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            if tracker.trackingType == .streak {
                                Text("Current Streak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Progress (if goal is set)
                        if tracker.goal != nil {
                            VStack(spacing: 12) {
                                ProgressView(value: trackersModel.getGoalProgress(tracker))
                                    .progressViewStyle(LinearProgressViewStyle(tint: trackersModel.getTrackerColor(tracker.color)))
                                    .scaleEffect(y: 2)
                                
                                HStack {
                                    Text(trackersModel.getGoalProgressText(tracker))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    let percentage = Int(trackersModel.getGoalProgress(tracker) * 100)
                                    Text("\(percentage)%")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(trackersModel.getTrackerColor(tracker.color))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    
                    // Stats Cards
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Longest Streak",
                            value: "\(tracker.longestStreak)",
                            subtitle: tracker.unit,
                            color: .green
                        )
                        
                        StatCard(
                            title: "Total Entries",
                            value: "\(tracker.history.count)",
                            subtitle: "records",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Days Active",
                            value: "\(daysSinceCreation())",
                            subtitle: "days",
                            color: .orange
                        )
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: { trackersModel.incrementTracker(tracker.id) }) {
                                HStack {
                                    if tracker.trackingType == .negativeEvent {
                                        Image(systemName: "exclamationmark.circle.fill")
                                    } else {
                                        Image(systemName: "plus.circle.fill")
                                    }
                                    Text(getIncrementText())
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(tracker.trackingType == .negativeEvent ? Color.red : trackersModel.getTrackerColor(tracker.color))
                                )
                            }
                            
                            Button(action: { showingAddEntry = true }) {
                                HStack {
                                    Image(systemName: "pencil.circle")
                                    Text("Manual")
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(trackersModel.getTrackerColor(tracker.color))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(trackersModel.getTrackerColor(tracker.color), lineWidth: 2)
                                )
                            }
                        }
                        
                        if tracker.trackingType == .streak || tracker.trackingType == .negativeEvent {
                            Button(action: { showingResetAlert = true }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text(tracker.trackingType == .negativeEvent ? "Reset Counter" : "Reset Streak")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                        }
                    }
                    
                    // Recent History
                    if !tracker.history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Activity")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(tracker.history.suffix(10).reversed(), id: \.id) { entry in
                                    HistoryEntryRow(entry: entry, unit: tracker.unit)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") { dismiss() },
                trailing: Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit Tracker", systemImage: "pencil")
                    }
                    
                    Button(action: { trackersModel.toggleTrackerActive(tracker) }) {
                        Label(tracker.isActive ? "Deactivate" : "Activate", 
                              systemImage: tracker.isActive ? "pause.circle" : "play.circle")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete Tracker", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTrackerView(tracker: tracker, trackersModel: trackersModel)
        }
        .sheet(isPresented: $showingAddEntry) {
            ManualEntryView(tracker: tracker, trackersModel: trackersModel)
        }
        .alert("Reset Streak", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                trackersModel.resetTracker(tracker.id, notes: "Manual reset")
                dismiss()
            }
        } message: {
            Text("This will reset your current streak to 0. This action cannot be undone.")
        }
        .alert("Delete Tracker", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                trackersModel.deleteTracker(tracker)
                dismiss()
            }
        } message: {
            Text("This will permanently delete this tracker and all its data. This action cannot be undone.")
        }
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
    
    private func daysSinceCreation() -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: tracker.dateCreated, to: Date()).day ?? 0
        return max(1, days)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct HistoryEntryRow: View {
    let entry: TrackerEntry
    let unit: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: iconForEntryType())
                        .font(.caption)
                        .foregroundColor(colorForEntryType())
                    
                    Text(textForEntryType())
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(entry.value) \(unit)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(colorForEntryType())
                }
                
                HStack {
                    Text(formatDate(entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let notes = entry.notes, !notes.isEmpty {
                        Spacer()
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    private func iconForEntryType() -> String {
        switch entry.type {
        case .increment:
            return "plus.circle.fill"
        case .reset:
            return "arrow.counterclockwise"
        case .manual:
            return "pencil.circle.fill"
        case .negativeEvent:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private func colorForEntryType() -> Color {
        switch entry.type {
        case .increment:
            return .green
        case .reset:
            return .red
        case .manual:
            return .blue
        case .negativeEvent:
            return .brown
        }
    }
    
    private func textForEntryType() -> String {
        switch entry.type {
        case .increment:
            return "Added"
        case .reset:
            return "Reset"
        case .manual:
            return "Manual Entry"
        case .negativeEvent:
            return "Event Recorded"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: date))"
        } else if Calendar.current.isDateInYesterday(date) {
            formatter.timeStyle = .short
            return "Yesterday at \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct ManualEntryView: View {
    let tracker: CustomTracker
    let trackersModel: CustomTrackersModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var value = 1
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text(tracker.emoji)
                        .font(.system(size: 60))
                    
                    Text("Manual Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add a custom value to \(tracker.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Value:")
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack {
                            Button(action: { if value > 1 { value -= 1 } }) {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            .disabled(value <= 1)
                            
                            Text("\(value)")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(minWidth: 60)
                            
                            Button(action: { value += 1 }) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text(tracker.unit)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.headline)
                        
                        TextField("Add a note...", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: addEntry) {
                        Text("Add Entry")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(trackersModel.getTrackerColor(tracker.color))
                            )
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .navigationBarHidden(true)
        }
    }
    
    private func addEntry() {
        let notesText = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        trackersModel.setTrackerValue(
            tracker.id,
            value: tracker.currentValue + value,
            notes: notesText.isEmpty ? nil : notesText
        )
        dismiss()
    }
}

struct EditTrackerView: View {
    @State private var tracker: CustomTracker
    let trackersModel: CustomTrackersModel
    @Environment(\.dismiss) private var dismiss
    
    init(tracker: CustomTracker, trackersModel: CustomTrackersModel) {
        self._tracker = State(initialValue: tracker)
        self.trackersModel = trackersModel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Similar form as CustomTrackerFormView but with existing values
                    Text("Edit functionality would go here")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Edit Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    trackersModel.updateTracker(tracker)
                    dismiss()
                }
            )
        }
    }
}

struct TrackerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerDetailView(
            tracker: CustomTracker(name: "Exercise", emoji: "💪", color: "blue", trackingType: .streak, unit: "days"),
            trackersModel: CustomTrackersModel()
        )
    }
}
