import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var connectionModel: PartnerConnectionModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editedProfile: UserProfile?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = connectionModel.userProfile {
                        // Profile Header
                        VStack(spacing: 16) {
                            Text(profile.profileEmoji)
                                .font(.system(size: 80))
                            
                            Text(profile.displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            if !profile.bio.isEmpty {
                                Text(profile.bio)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Profile Info Cards
                        VStack(spacing: 16) {
                            // Love Language
                            if let loveLanguage = profile.loveLanguage {
                                ProfileInfoCard(
                                    title: "Love Language",
                                    icon: loveLanguage.emoji,
                                    content: loveLanguage.rawValue,
                                    description: loveLanguage.description
                                )
                            }
                            
                            // Interests
                            if !profile.interests.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Interests")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    FlowLayout(spacing: 8) {
                                        ForEach(profile.interests, id: \.self) { interest in
                                            Text(interest)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.blue.opacity(0.1))
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.05))
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            // Connection Info
                            if let partner = profile.partnerProfile {
                                ProfileInfoCard(
                                    title: "Connected to",
                                    icon: partner.profileEmoji,
                                    content: partner.displayName,
                                    description: "Connected on \(formatDate(profile.dateCreated))"
                                )
                            } else {
                                ProfileInfoCard(
                                    title: "Connection Status",
                                    icon: "💔",
                                    content: "Not Connected",
                                    description: "Generate a pair code to connect with your partner"
                                )
                            }
                            
                            // Account Info
                            ProfileInfoCard(
                                title: "Account",
                                icon: "👤",
                                content: profile.name,
                                description: "Member since \(formatDate(profile.dateCreated))"
                            )
                        }
                        
                        Spacer(minLength: 40)
                    } else {
                        Text("No profile found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") { dismiss() },
                trailing: Button("Edit") { 
                    editedProfile = connectionModel.userProfile
                    isEditing = true 
                }
            )
        }
        .sheet(isPresented: $isEditing) {
            if let profile = editedProfile {
                EditProfileView(
                    profile: profile,
                    onSave: { updatedProfile in
                        connectionModel.updateProfile(updatedProfile)
                        isEditing = false
                    },
                    onCancel: { isEditing = false }
                )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ProfileInfoCard: View {
    let title: String
    let icon: String
    let content: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text(content)
                .font(.body)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(PartnerConnectionModel())
    }
}
