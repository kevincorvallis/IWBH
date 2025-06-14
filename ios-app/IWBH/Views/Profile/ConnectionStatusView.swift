import SwiftUI

struct ConnectionStatusView: View {
    let profile: UserProfile
    let onDisconnect: () -> Void
    let onGeneratePairCode: () -> Void
    let onEnterPartnerCode: () -> Void
    let pairCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if let partner = profile.partnerProfile {
                ConnectedStatusView(
                    partner: partner,
                    connectionDate: profile.dateCreated,
                    onDisconnect: onDisconnect
                )
            } else {
                NotConnectedStatusView(
                    pairCode: pairCode,
                    onGeneratePairCode: onGeneratePairCode,
                    onEnterPartnerCode: onEnterPartnerCode
                )
            }
        }
    }
}

struct ConnectedStatusView: View {
    let partner: PartnerInfo
    let connectionDate: Date
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
                Text(partner.profileEmoji)
                    .font(.title3)
                Text(partner.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            Text("Connected since \(formatDate(connectionDate))")
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct NotConnectedStatusView: View {
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
            
            // Pairing Code Display
            if !pairCode.isEmpty {
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
                        // TODO: Add haptic feedback
                    }) {
                        Label("Copy Code", systemImage: "doc.on.doc")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 8)
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
}
