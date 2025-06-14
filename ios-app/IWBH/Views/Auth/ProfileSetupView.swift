import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @ObservedObject var authModel: AuthenticationModel
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var selectedEmoji: String = "💝"
    @State private var selectedLoveLanguage: LoveLanguage? = nil
    @State private var interests: [String] = []
    @State private var newInterest: String = ""
    @State private var showingEmojiPicker = false
    @State private var showingLogoutConfirmation = false
    private let emojiOptions = ["💝", "💕", "💖", "💗", "💓", "💞", "💘", "❤️", "🧡", "💛", "💚", "💙", "💜", "🤍", "🖤", "🤎", "🌹", "✨", "🦋", "🌟"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Create Your Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Let's set up your profile so you can connect with your partner")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Profile Picture (Emoji)
                    VStack(spacing: 16) {
                        Button(action: { showingEmojiPicker = true }) {
                            Text(selectedEmoji)
                                .font(.system(size: 80))
                                .frame(width: 120, height: 120)
                                .background(
                                    Circle()
                                        .fill(Color.pink.opacity(0.1))
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                                )
                        }
                        
                        Text("Tap to choose your emoji")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Display Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("How should your partner see you?", text: $displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Tell your partner about yourself...", text: $bio, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .font(.body)
                    }
                    
                    // Love Language
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Love Language")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(LoveLanguage.allCases, id: \.self) { language in
                                Button(action: {
                                    selectedLoveLanguage = language
                                }) {
                                    VStack(spacing: 8) {
                                        Text(language.emoji)
                                            .font(.largeTitle)
                                        
                                        Text(language.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedLoveLanguage == language ?
                                                  Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
                                            .stroke(selectedLoveLanguage == language ?
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
                                if !newInterest.isEmpty && !interests.contains(newInterest) {
                                    interests.append(newInterest)
                                    newInterest = ""
                                }
                            }
                            .disabled(newInterest.isEmpty)
                        }
                        
                        if !interests.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(interests, id: \.self) { interest in
                                    InterestTag(text: interest) {
                                        interests.removeAll { $0 == interest }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Create Profile Button
                    Button(action: createProfile) {
                        HStack {
                            Text("Create Profile")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(canCreateProfile ? Color.pink : Color.gray)
                        )
                    }
                    .disabled(!canCreateProfile)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    authModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $selectedEmoji, emojiOptions: emojiOptions)
        }
        .onAppear {
            displayName = authModel.userName
        }
    }
    
    private var canCreateProfile: Bool {
        !displayName.isEmpty && selectedLoveLanguage != nil
    }
    
    private func createProfile() {
        var profile = UserProfile(userID: authModel.userID, name: authModel.userName)
        profile.displayName = displayName
        profile.bio = bio
        profile.profileEmoji = selectedEmoji
        profile.loveLanguage = selectedLoveLanguage
        profile.interests = interests
        
        connectionModel.updateProfile(profile)
    }
}


struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var yOffset: CGFloat = bounds.minY
        
        for row in rows {
            var xOffset: CGFloat = bounds.minX
            
            for subview in row.subviews {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: xOffset, y: yOffset), proposal: ProposedViewSize(size))
                xOffset += size.width + spacing
            }
            
            yOffset += row.height + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentRow.width + size.width + spacing > maxWidth && !currentRow.subviews.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }
            
            currentRow.subviews.append(subview)
            currentRow.width += size.width + spacing
            currentRow.height = max(currentRow.height, size.height)
        }
        
        if !currentRow.subviews.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var subviews: [LayoutSubview] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView(
            connectionModel: PartnerConnectionModel(),
            authModel: AuthenticationModel()
        )
    }
}
