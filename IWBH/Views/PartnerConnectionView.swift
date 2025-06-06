import SwiftUI

struct PartnerConnectionView: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @State private var showingProfileSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("💕")
                            .font(.system(size: 60))
                        
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
                    
                    // Connection Status
                    connectionStatusView
                    
                    // Connection Actions
                    connectionActionsView
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarItems(
                leading: profileButton,
                trailing: settingsButton
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $connectionModel.showingPairCodeSheet) {
            PairCodeSheet(connectionModel: connectionModel)
        }
        .sheet(isPresented: $connectionModel.showingEnterCodeSheet) {
            EnterCodeSheet(connectionModel: connectionModel)
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileView()
                .environmentObject(connectionModel)
        }
    }
    
    @ViewBuilder
    private var connectionStatusView: some View {
        switch connectionModel.pairingStatus {
        case .unpaired:
            UnpairedStatusView()
        case .waitingForPartner:
            WaitingStatusView(pairCode: connectionModel.pairCode)
        case .paired:
            PairedStatusView(partner: connectionModel.userProfile?.partnerProfile)
        case .pairingFailed:
            FailedStatusView()
        }
    }
    
    @ViewBuilder
    private var connectionActionsView: some View {
        VStack(spacing: 16) {
            switch connectionModel.pairingStatus {
            case .unpaired:
                VStack(spacing: 12) {
                    Button(action: {
                        connectionModel.generatePairCode()
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Generate Pair Code")
                                .fontWeight(.semibold)
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
                    
                    Text("or")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Button(action: {
                        connectionModel.showingEnterCodeSheet = true
                    }) {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("Enter Partner's Code")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.pink, lineWidth: 2)
                        )
                    }
                }
                
            case .waitingForPartner:
                Button(action: {
                    connectionModel.showingEnterCodeSheet = true
                }) {
                    HStack {
                        Image(systemName: "keyboard")
                        Text("Enter Partner's Code Instead")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
                
            case .paired:
                Button(action: {
                    connectionModel.unpair()
                }) {
                    HStack {
                        Image(systemName: "person.2.slash")
                        Text("Unpair")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 2)
                    )
                }
                
            case .pairingFailed:
                Button(action: {
                    connectionModel.showingEnterCodeSheet = true
                }) {
                    HStack {
                        Image(systemName: "keyboard")
                        Text("Try Again")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange)
                    )
                }
            }
        }
    }
    
    private var profileButton: some View {
        Button(action: { showingProfileSheet = true }) {
            if let profile = connectionModel.userProfile {
                Text(profile.profileEmoji)
                    .font(.title2)
            } else {
                Image(systemName: "person.circle")
                    .font(.title2)
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {}) {
            Image(systemName: "gearshape")
                .font(.title2)
        }
    }
}

// MARK: - Status Views

struct UnpairedStatusView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Not Connected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Generate a pair code for your partner or enter their code to connect")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct WaitingStatusView: View {
    let pairCode: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Waiting for Connection")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Share this code with your partner:")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text(pairCode)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.monospaced)
                .foregroundColor(.pink)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.pink.opacity(0.1))
                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct PairedStatusView: View {
    let partner: PartnerInfo?
    
    var body: some View {
        VStack(spacing: 16) {
            if let partner = partner {
                Text(partner.profileEmoji)
                    .font(.system(size: 50))
                
                Text("Connected to \(partner.displayName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Circle()
                        .fill(partner.isOnline ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(partner.isOnline ? "Online" : "Last seen recently")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !partner.bio.isEmpty {
                    Text(partner.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
}

struct FailedStatusView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Connection Failed")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Unable to connect with your partner. Please try again.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - Sheet Views

struct PairCodeSheet: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("🔗")
                        .font(.system(size: 80))
                    
                    Text("Your Pair Code")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Share this code with your partner")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Text(connectionModel.pairCode)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.pink)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.pink.opacity(0.1))
                                .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                        )
                    
                    Button(action: {
                        UIPasteboard.general.string = connectionModel.pairCode
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Code")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Text("This code will expire in 15 minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Pair Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct EnterCodeSheet: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @Environment(\.dismiss) private var dismiss
    @State private var enteredCode = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("💝")
                        .font(.system(size: 80))
                    
                    Text("Enter Partner's Code")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter the 6-digit code from your partner")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    TextField("000000", text: $enteredCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: enteredCode) { newValue in
                            if newValue.count > 6 {
                                enteredCode = String(newValue.prefix(6))
                            }
                        }
                    
                    if let error = connectionModel.pairingError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Button(action: {
                    connectionModel.enterPairCode(enteredCode)
                }) {
                    HStack {
                        if connectionModel.isPairing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Connect")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(enteredCode.count == 6 ? Color.pink : Color.gray)
                    )
                }
                .disabled(enteredCode.count != 6 || connectionModel.isPairing)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Enter Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
}

struct PartnerConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerConnectionView(connectionModel: PartnerConnectionModel())
    }
}