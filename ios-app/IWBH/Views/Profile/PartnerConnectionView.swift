import SwiftUI

struct PartnerConnectionView: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @ObservedObject var authModel: AuthenticationModel // Add this
    @State private var showingProfileSheet = false
    @State private var showingSettingsSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    header
                    statusView
                    actionsView
                    Spacer()
                }
                .padding(.horizontal, 24)
                .animation(.easeInOut, value: connectionModel.pairingStatus)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { profileButton }
                ToolbarItem(placement: .navigationBarTrailing) { settingsButton }
            }
        }
        .sheet(isPresented: $connectionModel.showingPairCodeSheet) {
            PairCodeSheet(connectionModel: connectionModel)
        }
        .sheet(isPresented: $connectionModel.showingEnterCodeSheet) {
            EnterCodeSheet(connectionModel: connectionModel)
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSheet()
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsSheet(
                onLogout: {
                    authModel.signOut()
                },
                onContinueAsGuest: {
                    authModel.continueAsGuest()
                    connectionModel.createProfile(
                        userID: authModel.userID,
                        name: authModel.userName
                    )
                    connectionModel.pairingStatus = .paired
                }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            Text("💕")
                .font(.system(size: 60))
                .transition(.scale)
            Text("Connect with Your Partner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Share moments, track activities, and stay connected")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    @ViewBuilder
    private var statusView: some View {
        Group {
            switch connectionModel.pairingStatus {
            case .unpaired:
                UnpairedStatusView()
            case .waitingForPartner:
                WaitingStatusView(pairCode: connectionModel.pairCode)
            case .paired:
                if let partner = connectionModel.userProfile {
                    PairedStatusView(partner: partner)
                } else {
                    Text("No Partner Profile").foregroundColor(.secondary)
                }
            case .pairingFailed:
                FailedStatusView()
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    @ViewBuilder
    private var actionsView: some View {
        VStack(spacing: 16) {
            switch connectionModel.pairingStatus {
            case .unpaired:
                VStack(spacing: 12) {
                    generateCodeButton
                    Text("or").font(.caption).foregroundColor(.secondary)
                    enterCodeButton
                }
            case .waitingForPartner:
                enterCodeInsteadButton
            case .paired:
                unpairButton
            case .pairingFailed:
                tryAgainButton
            }
        }
    }

    private var generateCodeButton: some View {
        Button(action: connectionModel.generatePairCode) {
            HStack {
                if connectionModel.isGeneratingCode {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "qrcode")
                }
                Text("Generate Pair Code").fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pink)
            )
        }
        .disabled(connectionModel.isGeneratingCode)
    }

    private var enterCodeButton: some View {
        ActionButton(title: "Enter Partner's Code", systemImage: "keyboard", color: .pink) {
            connectionModel.showingEnterCodeSheet = true
        }
    }

    private var enterCodeInsteadButton: some View {
        ActionButton(title: "Enter Partner's Code Instead", systemImage: "keyboard", color: .blue) {
            connectionModel.showingEnterCodeSheet = true
        }
    }

    private var unpairButton: some View {
        ActionButton(title: "Unpair", systemImage: "person.2.slash", color: .red) {
            connectionModel.unpair()
        }
    }

    private var tryAgainButton: some View {
        Button(action: { connectionModel.showingEnterCodeSheet = true }, label: {
            HStack {
                Image(systemName: "keyboard")
                Text("Try Again").fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange)
            )
        })
    }

    private var profileButton: some View {
        Button(action: { showingProfileSheet = true }, label: {
            if let profile = connectionModel.userProfile {
                Text(profile.profileEmoji).font(.title2)
            } else {
                Image(systemName: "person.circle").font(.title2)
            }
        })
    }

    private var settingsButton: some View {
        Button(action: { showingSettingsSheet = true }, label: {
            Image(systemName: "gearshape")
                .font(.title2)
        })
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title).fontWeight(.semibold)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
            )
        }
    }
}
