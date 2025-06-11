import SwiftUI
import AuthenticationServices

// MARK: - ProfileView
struct ProfileView: View {
    @EnvironmentObject var connectionModel: PartnerConnectionModel
    @EnvironmentObject var authModel: AuthenticationModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedProfile: UserProfile?
    @State private var showingLogoutConfirmation = false
    @State private var showingDisconnectConfirmation = false
    @State private var showPairingSheet = false
    @State private var showAccountDeletionView = false
    
    @State private var showExitGuestModeConfirmation = false
    @State private var showDeleteGuestAccountConfirmation = false
    @State private var showingDeleteFeedbackSheet = false
    @State private var showDeletionSuccessAlert = false
    @State private var showDeletionFailureAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                contentContainer
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingToolbarItem
                trailingToolbarItem
            }
        }
        .sheet(isPresented: $isEditing) {
            profileEditSheet
        }
        .sheet(isPresented: $showPairingSheet) {
            pairingSheet
        }
        .sheet(isPresented: $showAccountDeletionView) {
            AccountDeletionView()
        }
        .sheet(isPresented: $showingDeleteFeedbackSheet) {
            accountDeletionFeedbackSheet
        }
        .alert("Guest Account Deleted", isPresented: $showDeletionSuccessAlert) {
            Button("OK") {
                authModel.signOut()
                dismiss()
            }
        }
        .alert("Failed to Delete Guest Account", isPresented: $showDeletionFailureAlert) {
            Button("OK", role: .cancel) {}
        }
        .confirmationDialog(
            "Are you sure you want to log out?",
            isPresented: $showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                authModel.signOut()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Are you sure you want to disconnect from your partner?",
            isPresented: $showingDisconnectConfirmation,
            titleVisibility: .visible
        ) {
            Button("Disconnect", role: .destructive) {
                disconnectFromPartner()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove your connection and you'll need to reconnect using a pairing code.")
        }
        .alert("Exit Guest Mode?", isPresented: $showExitGuestModeConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) {
                authModel.exitGuestMode()
                dismiss()
            }
        } message: {
            Text("You'll need to sign in or create an account to continue using the app.")
        }
        .alert("Delete Guest Account?", isPresented: $showDeleteGuestAccountConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                showingDeleteFeedbackSheet = true
            }
        } message: {
            Text("This will permanently delete all your guest account data. This action cannot be undone.")
        }
    }
    
    // MARK: - UI Components
    
    private var contentContainer: some View {
        VStack(spacing: 24) {
            if let profile = connectionModel.userProfile {
                ProfileHeaderComponent(
                    emoji: profile.profileEmoji,
                    name: profile.displayName,
                    bio: profile.bio,
                    email: authModel.userEmail.isEmpty ? profile.userID : authModel.userEmail
                )
                
                ProfileDetailsComponent(
                    profile: profile,
                    connectionModel: connectionModel,
                    onEditProfile: {
                        editedProfile = profile
                        isEditing = true
                    },
                    onDisconnect: {
                        showingDisconnectConfirmation = true
                    },
                    onGeneratePairCode: {
                        connectionModel.generatePairCode()
                    },
                    onEnterPartnerCode: {
                        showPairingSheet = true
                    },
                    onLogout: {
                        showingLogoutConfirmation = true
                    }
                )
                
                if authModel.isGuest {
                    GuestModeComponent(
                        onExit: { showExitGuestModeConfirmation = true },
                        onDelete: { showDeleteGuestAccountConfirmation = true }
                    )
                }
                
                Spacer(minLength: 40)
            } else {
                Text("No profile found")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    private var leadingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Done") { dismiss() }
        }
    }
    
    private var trailingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Edit") {
                editedProfile = connectionModel.userProfile
                isEditing = true
            }
        }
    }
    
    private var profileEditSheet: some View {
        Group {
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
    
    private var pairingSheet: some View {
        EnterPairCodeView(
            onSubmit: { code in
                connectionModel.enterPartnerCode(code)
                showPairingSheet = false
            },
            onCancel: { showPairingSheet = false }
        )
    }
    
    private var accountDeletionFeedbackSheet: some View {
        AccountDeletionFeedbackView(
            onSubmit: { feedback in
                authModel.deleteGuestAccount(feedback: feedback) { result in
                    switch result {
                    case .success:
                        showDeletionSuccessAlert = true
                    case .failure:
                        showDeletionFailureAlert = true
                    }
                }
                showingDeleteFeedbackSheet = false
            },
            onCancel: {
                showingDeleteFeedbackSheet = false
            }
        )
    }
    
    // MARK: - Helper Methods
    
    private func disconnectFromPartner() {
        guard var profile = connectionModel.userProfile else { return }
        profile.partnerId = nil
        profile.partnerProfile = nil
        connectionModel.updateProfile(profile)
    }
}

// MARK: - Component Views

// Profile Header Component
struct ProfileHeaderComponent: View {
    let emoji: String
    let name: String
    let bio: String
    let email: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 80))
            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
            if !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            Text(email)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}

// Profile Details Component
struct ProfileDetailsComponent: View {
    let profile: UserProfile
    let connectionModel: PartnerConnectionModel
    let onEditProfile: () -> Void
    let onDisconnect: () -> Void
    let onGeneratePairCode: () -> Void
    let onEnterPartnerCode: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Love Language
            loveLanguageSection
            
            // Interests
            interestsSection
            
            // Partner Connection
            partnerConnectionSection
            
            // Account Info
            accountInfoSection
            
            // Logout
            logoutButton
        }
    }
    
    private var loveLanguageSection: some View {
        Group {
            if let loveLanguage = profile.loveLanguage {
                ProfileInfoCard(
                    title: "Love Language",
                    icon: loveLanguage.emoji,
                    content: loveLanguage.rawValue,
                    description: loveLanguage.description
                )
            }
        }
    }
    
    private var interestsSection: some View {
        Group {
            if !profile.interests.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Interests")
                        .font(.headline)
                    FlowLayout(spacing: 8) {
                        ForEach(profile.interests, id: \.self) { interest in
                            InterestTagView(text: interest)
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
        }
    }
    
    private var partnerConnectionSection: some View {
        Group {
            if let partner = profile.partnerProfile {
                ConnectedPartnerView(
                    partnerEmoji: partner.profileEmoji,
                    partnerName: partner.displayName,
                    connectedSince: formatDate(profile.dateCreated),
                    onDisconnect: onDisconnect
                )
            } else {
                NotConnectedView(
                    pairCode: connectionModel.pairCode,
                    onGeneratePairCode: onGeneratePairCode,
                    onEnterPartnerCode: onEnterPartnerCode
                )
            }
        }
    }
    
    private var accountInfoSection: some View {
        ProfileInfoCard(
            title: "Account",
            icon: "👤",
            content: profile.name,
            description: "Member since \(formatDate(profile.dateCreated))"
        )
    }
    
    private var logoutButton: some View {
        Button(action: onLogout) {
            HStack {
                Spacer()
                Text("Log Out")
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct GuestModeComponent: View {
    let onExit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guest Mode").font(.headline)
            Button(action: onExit) {
                HStack {
                    Text("Exit Guest Mode")
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                .foregroundColor(.blue)
            }
            Button(action: onDelete) {
                HStack {
                    Text("Delete Guest Account")
                    Spacer()
                    Image(systemName: "trash")
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct InterestTagView: View {
    let text: String
    
    var body: some View {
        Text(text)
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

struct ConnectedPartnerView: View {
    let partnerEmoji: String
    let partnerName: String
    let connectedSince: String
    let onDisconnect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💞")
                    .font(.title2)
                Text("Connected to")
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text(partnerEmoji)
                    .font(.title3)
                Text(partnerName)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            Text("Connected since \(connectedSince)")
                .font(.caption)
                .foregroundColor(.secondary)
            Button(action: onDisconnect) {
                Text("Disconnect")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pink.opacity(0.1))
                .stroke(Color.pink.opacity(0.3), lineWidth: 1)
        )
    }
}

struct NotConnectedView: View {
    let pairCode: String
    let onGeneratePairCode: () -> Void
    let onEnterPartnerCode: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💔")
                    .font(.title2)
                Text("Not Connected")
                    .font(.headline)
                Spacer()
            }
            Text("Connect with your partner to share moments and activities")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !pairCode.isEmpty {
                pairCodeDisplay
            }
            
            HStack(spacing: 12) {
                Button(action: onGeneratePairCode) {
                    Text("Generate Pair Code")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Button(action: onEnterPartnerCode) {
                    Text("Enter Partner Code")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .foregroundColor(.blue)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
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
    
    private var pairCodeDisplay: some View {
        VStack(spacing: 8) {
            Text("Your pairing code:")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(pairCode)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            Button(action: {
                UIPasteboard.general.string = pairCode
            }) {
                Label("Copy Code", systemImage: "doc.on.doc")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
    }
}

struct EditProfileView: View {
    let profile: UserProfile
    let onSave: (UserProfile) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Edit Profile")
                .font(.headline)
            // Add fields for editing profile details
            Button("Save") {
                onSave(profile)
            }
            Button("Cancel") {
                onCancel()
            }
        }
        .padding()
    }
}

struct AccountDeletionFeedbackView: View {
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    @State private var feedback: String = ""

    var body: some View {
        VStack {
            Text("Provide Feedback")
                .font(.headline)
            TextField("Feedback", text: $feedback)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Submit") {
                onSubmit(feedback)
            }
            Button("Cancel") {
                onCancel()
            }
        }
        .padding()
    }
}

struct ProfileInfoCard: View {
    let title: String
    let icon: String
    let content: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title)
                Text(title)
                    .font(.headline)
            }
            Text(content)
                .font(.body)
                .fontWeight(.medium)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
