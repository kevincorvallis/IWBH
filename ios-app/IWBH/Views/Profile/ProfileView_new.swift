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
    @State private var showGuestDeletionSuccessAlert = false
    @State private var showGuestDeletionFailureAlert = false
    @State private var showAccountDeletionSuccessAlert = false
    @State private var showAccountDeletionFailureAlert = false

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
            AccountDeletionView(
                onConfirm: { feedback in
                    authModel.deleteAccount(feedback: feedback) { result in
                        switch result {
                        case .success:
                            showAccountDeletionSuccessAlert = true
                        case .failure(let error):
                            print("Account deletion failed: \(error)")
                            showAccountDeletionFailureAlert = true
                        }
                    }
                    showAccountDeletionView = false
                },
                onCancel: {
                    showAccountDeletionView = false
                }
            )
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
        .confirmationDialog(
            "Exit Guest Mode",
            isPresented: $showExitGuestModeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Exit", role: .destructive) {
                authModel.exitGuestMode()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your data will be lost if you exit guest mode without creating an account.")
        }
        .confirmationDialog(
            "Delete Guest Account",
            isPresented: $showDeleteGuestAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                showingDeleteFeedbackSheet = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your guest account and all data.")
        }
        .sheet(isPresented: $showingDeleteFeedbackSheet) {
            AccountDeletionFeedbackView(
                onSubmit: { feedback in
                    authModel.deleteGuestAccount(feedback: feedback) { result in
                        switch result {
                        case .success:
                            showGuestDeletionSuccessAlert = true
                        case .failure:
                            showGuestDeletionFailureAlert = true
                        }
                    }
                    showingDeleteFeedbackSheet = false
                },
                onCancel: {
                    showingDeleteFeedbackSheet = false
                }
            )
        }
        .alert("Account Deleted", isPresented: $showAccountDeletionSuccessAlert) {
            Button("OK") {}
        } message: {
            Text("Your account has been successfully deleted.")
        }
        .alert("Deletion Failed", isPresented: $showAccountDeletionFailureAlert) {
            Button("OK") {}
        } message: {
            Text("Failed to delete account. Please try again.")
        }
        .alert("Guest Account Deleted", isPresented: $showGuestDeletionSuccessAlert) {
            Button("OK") {}
        } message: {
            Text("Your guest account has been successfully deleted.")
        }
        .alert("Deletion Failed", isPresented: $showGuestDeletionFailureAlert) {
            Button("OK") {}
        } message: {
            Text("Failed to delete guest account. Please try again.")
        }
    }

    // MARK: - View Components
    private var contentContainer: some View {
        VStack(spacing: 24) {
            if let profile = connectionModel.userProfile {
                profileHeader(profile)
                profileInfoSection(profile)
                connectionSection(profile)
                accountSection(profile)
                actionButtons
            } else {
                Text("No profile found")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private func profileHeader(_ profile: UserProfile) -> some View {
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
                    .padding(.horizontal, 24)
            }

            Text(authModel.userEmail.isEmpty ? profile.userID : authModel.userEmail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }

    private func profileInfoSection(_ profile: UserProfile) -> some View {
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
        }
    }

    private func connectionSection(_ profile: UserProfile) -> some View {
        ConnectionStatusView(
            profile: profile,
            onDisconnect: {
                showingDisconnectConfirmation = true
            },
            onGeneratePairCode: {
                connectionModel.generatePairCode()
            },
            onEnterPartnerCode: {
                showPairingSheet = true
            },
            pairCode: connectionModel.pairCode
        )
    }

    private func accountSection(_ profile: UserProfile) -> some View {
        ProfileInfoCard(
            title: "Account",
            icon: "👤",
            content: profile.name,
            description: "Member since \(formatDate(profile.dateCreated))"
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if authModel.isGuest {
                guestModeButtons
            } else {
                regularUserButtons
            }
        }
    }

    private var guestModeButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showExitGuestModeConfirmation = true
            }) {
                HStack {
                    Spacer()
                    Text("Exit Guest Mode")
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }

            Button(action: {
                showDeleteGuestAccountConfirmation = true
            }) {
                HStack {
                    Spacer()
                    Text("Delete Guest Account")
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
    }

    private var regularUserButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingLogoutConfirmation = true
            }) {
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

            Button(action: {
                showAccountDeletionView = true
            }) {
                HStack {
                    Spacer()
                    Text("Delete Account")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Toolbar Items
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

    // MARK: - Sheet Content
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
            onCancel: {
                showPairingSheet = false
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AccountDeletionFeedbackView: View {
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    @State private var feedback: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Help Us Improve")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("We're sorry to see you go. Would you mind sharing why you're deleting your account?")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                TextEditor(text: $feedback)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                VStack(spacing: 12) {
                    Button(action: {
                        onSubmit(feedback)
                    }) {
                        HStack {
                            Spacer()
                            Text("Submit & Delete Account")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }

                    Button(action: onCancel) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel", action: onCancel))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(PartnerConnectionModel())
            .environmentObject(AuthenticationModel())
    }
}
