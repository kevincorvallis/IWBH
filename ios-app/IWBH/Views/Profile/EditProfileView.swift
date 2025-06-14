import SwiftUI

struct EditProfileView: View {
    @State private var profile: UserProfile
    let onSave: (UserProfile) -> Void
    let onCancel: () -> Void
    
    @State private var showingEmojiPicker = false
    @State private var newInterest = ""
    
    private let emojiOptions = ["💝", "💕", "💖", "💗", "💓", "💞", "💘", "❤️", "🧡", "💛", "💚", "💙", "💜", "🤍", "🖤", "🤎", "🌹", "✨", "🦋", "🌟"]
    
    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void, onCancel: @escaping () -> Void) {
        self._profile = State(initialValue: profile)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture (Emoji)
                    VStack(spacing: 16) {
                        Button(action: { showingEmojiPicker = true }) {
                            Text(profile.profileEmoji)
                                .font(.system(size: 80))
                                .frame(width: 120, height: 120)
                                .background(
                                    Circle()
                                        .fill(Color.pink.opacity(0.1))
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                                )
                        }
                        
                        Text("Tap to change emoji")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Display Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Display Name", text: $profile.displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Bio", text: $profile.bio, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Love Language
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Love Language")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(LoveLanguage.allCases, id: \.self) { language in
                                Button(action: {
                                    profile.loveLanguage = language
                                }) {
                                    VStack(spacing: 8) {
                                        Text(language.emoji)
                                            .font(.title)
                                        
                                        Text(language.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(profile.loveLanguage == language ?
                                                  Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
                                            .stroke(profile.loveLanguage == language ?
                                                   Color.pink : Color.clear, lineWidth: 2)
                                    )
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // Interests
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("Add an interest", text: $newInterest)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !newInterest.isEmpty && !profile.interests.contains(newInterest) {
                                    profile.interests.append(newInterest)
                                    newInterest = ""
                                }
                            }
                            .disabled(newInterest.isEmpty)
                        }
                        
                        if !profile.interests.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(profile.interests, id: \.self) { interest in
                                    InterestTag(text: interest) {
                                        profile.interests.removeAll { $0 == interest }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { onCancel() },
                trailing: Button("Save") { onSave(profile) }
            )
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $profile.profileEmoji, emojiOptions: emojiOptions)
        }
    }
}


