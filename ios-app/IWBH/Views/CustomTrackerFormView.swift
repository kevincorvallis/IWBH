import SwiftUI

struct CustomTrackerFormView: View {
    let trackersModel: CustomTrackersModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var emoji = "📊"
    @State private var selectedColor = "blue"
    @State private var trackingType: TrackingType = .streak
    @State private var unit = "days"
    @State private var hasGoal = false
    @State private var goal = 30
    @State private var showingEmojiPicker = false
    
    private let colors = ["red", "blue", "green", "yellow", "orange", "purple", "pink", "indigo", "teal", "mint"]
    private let commonEmojis = ["📊", "🎯", "⭐", "🏆", "💪", "🧘‍♀️", "📚", "💧", "🏃‍♀️", "🌱", "❤️", "🧠", "🎨", "✍️", "🍎", "😴", "🌞", "🎵", "📱", "💻"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Emoji Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.headline)
                        
                        Button(action: { showingEmojiPicker = true }) {
                            HStack {
                                Text(emoji)
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                
                                Text("Tap to change")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                        
                        TextField("Enter tracker name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(getColor(color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Tracking Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tracking Type")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(TrackingType.allCases, id: \.self) { type in
                                Button(action: { 
                                    trackingType = type
                                    updateUnitForType(type)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(type.rawValue.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            Text(type.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if trackingType == type {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(getColor(selectedColor))
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(trackingType == type ? getColor(selectedColor).opacity(0.1) : Color.clear)
                                            .stroke(trackingType == type ? getColor(selectedColor) : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Unit
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .font(.headline)
                        
                        TextField("e.g., days, times, hours", text: $unit)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Goal
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Set Goal", isOn: $hasGoal)
                            .font(.headline)
                        
                        if hasGoal {
                            HStack {
                                Text("Goal:")
                                    .foregroundColor(.secondary)
                                
                                TextField("0", value: $goal, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 80)
                                
                                Text(unit)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Create Button
                    Button(action: createTracker) {
                        Text("Create Tracker")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canCreate ? getColor(selectedColor) : Color.gray)
                            )
                    }
                    .disabled(!canCreate)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("Custom Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerSheet(selectedEmoji: $emoji, emojis: commonEmojis)
        }
    }
    
    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func updateUnitForType(_ type: TrackingType) {
        switch type {
        case .streak:
            unit = "days"
        case .counter:
            unit = "times"
        case .timer:
            unit = "minutes"
        case .negativeEvent:
            unit = "days"
        }
    }
    
    private func createTracker() {
        let tracker = CustomTracker(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji,
            color: selectedColor,
            trackingType: trackingType,
            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
            goal: hasGoal ? goal : nil
        )
        
        trackersModel.addTracker(tracker)
        dismiss()
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

struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    let emojis: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                        .stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct CustomTrackerFormView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTrackerFormView(trackersModel: CustomTrackersModel())
    }
}
