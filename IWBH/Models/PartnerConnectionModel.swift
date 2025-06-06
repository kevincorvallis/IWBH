import SwiftUI
import Foundation
import Combine
import FirebaseFirestore

// MARK: - PartnerConnectionModel
@MainActor
class PartnerConnectionModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var pairingStatus: PairingStatus = .unpaired
    @Published var pairCode: String = ""
    @Published var isGeneratingCode = false
    @Published var isPairing = false
    @Published var pairingError: String?
    @Published var showingPairCodeSheet = false
    @Published var showingEnterCodeSheet = false
    @Published var connectionHealthy = true
    @Published var lastSyncTime = Date()

    private var partnerListener: ListenerRegistration?
    private var pairCodeTimer: Timer?
    private let db = Firestore.firestore()

    init() { loadProfile() }
    deinit { partnerListener?.remove() }

    func generatePairCode() {
        isGeneratingCode = true
        pairingError = nil
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        pairCode = code
        userProfile?.pairCode = code
        saveProfile()
        pairCodeTimer?.invalidate()
        pairCodeTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: false) { [weak self] _ in
            Task { await self?.expirePairCode() }
        }
        isGeneratingCode = false
        pairingStatus = .waitingForPartner
        showingPairCodeSheet = true
    }

    private func expirePairCode() async {
        userProfile?.pairCode = nil
        saveProfile()
        pairCode = ""
        pairingStatus = .unpaired
        pairingError = "Pair code expired. Please generate a new one."
        pairCodeTimer?.invalidate()
    }

    func enterPartnerCode(_ code: String) {
        guard code.count == 6 else {
            pairingError = "Please enter a 6-digit code."
            return
        }
        isPairing = true
        pairingError = nil
        Task { await searchForPairCodeInFirebase(code) }
    }

    private func searchForPairCodeInFirebase(_ code: String) async {
        guard let currentUserID = userProfile?.userID else {
            pairingError = "User profile not available."
            isPairing = false
            return
        }
        do {
            let doc = try await db.collection("pairCodes").document(code).getDocument()
            guard let data = doc.data(), doc.exists else {
                pairingError = "Invalid code."
                isPairing = false
                return
            }
            let partnerUserID = data["userID"] as? String ?? ""
            if partnerUserID == currentUserID {
                pairingError = "You cannot pair with yourself."
                isPairing = false
                return
            }
            await completePairing(partnerUserID: partnerUserID)
        } catch {
            pairingError = "Error: \(error.localizedDescription)"
        }
        isPairing = false
    }

    private func completePairing(partnerUserID: String) async {
        let partnerInfo = PartnerInfo(
            userID: partnerUserID,
            name: "Partner",
            displayName: "My Love",
            profileEmoji: "💕",
            bio: "Connected with love",
            isOnline: true,
            lastSeen: Date()
        )
        userProfile?.partnerId = partnerUserID
        userProfile?.partnerProfile = partnerInfo
        userProfile?.pairCode = nil
        saveProfile()
        pairingStatus = .paired
        showingEnterCodeSheet = false
        await setupFirebaseListeners()
    }

    func unpair() {
        userProfile?.partnerId = nil
        userProfile?.partnerProfile = nil
        userProfile?.pairCode = nil
        saveProfile()
        pairingStatus = .unpaired
        pairCode = ""
        partnerListener?.remove()
    }

    func createProfile(userID: String, name: String) {
        userProfile = UserProfile(userID: userID, name: name)
        saveProfile()
    }

    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
            updatePairingStatus()
        }
    }

    func updateProfile(_ updatedProfile: UserProfile) {
        userProfile = updatedProfile
        saveProfile()
        updatePairingStatus()
    }

    private func saveProfile() {
        guard let profile = userProfile else { return }
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }

    private func updatePairingStatus() {
        guard let profile = userProfile else {
            pairingStatus = .unpaired
            return
        }
        if profile.partnerId != nil {
            pairingStatus = .paired
        } else if profile.pairCode != nil {
            pairingStatus = .waitingForPartner
            pairCode = profile.pairCode ?? ""
        } else {
            pairingStatus = .unpaired
        }
    }

    func setupFirebaseListeners() async {
        guard let partnerID = userProfile?.partnerId else { return }
        partnerListener?.remove()
        partnerListener = db.collection("users").document(partnerID)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self,
                      let doc = snapshot, doc.exists,
                      let data = doc.data(),
                      var partnerProfile = self.userProfile?.partnerProfile else { return }
                partnerProfile.isOnline = data["isOnline"] as? Bool ?? false
                if let lastSeen = data["lastSeen"] as? Timestamp {
                    partnerProfile.lastSeen = lastSeen.dateValue()
                }
                self.userProfile?.partnerProfile = partnerProfile
                self.saveProfile()
                self.connectionHealthy = true
                self.lastSyncTime = Date()
            }
    }

    func formatLastSeen(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    func isPartnerOnline() -> Bool {
        userProfile?.partnerProfile?.isOnline ?? false
    }
}

// MARK: - Supporting Views
struct PairCodeSheet: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Your Pair Code")
            Text(connectionModel.pairCode).font(.largeTitle).monospaced()
            Button("Close") { dismiss() }
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct EnterCodeSheet: View {
    @ObservedObject var connectionModel: PartnerConnectionModel
    @State private var enteredCode: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 16) {
            TextField("Enter Partner Code", text: $enteredCode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            Button("Connect") {
                connectionModel.enterPartnerCode(enteredCode)
                dismiss()
            }
            .foregroundColor(.blue)
            Button("Cancel") { dismiss() }
                .foregroundColor(.red)
        }
        .padding()
    }
}

struct ProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.title)
            Button("Close") { dismiss() }
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct UnpairedStatusView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.slash")
            Text("You are unpaired.")
        }
    }
}

struct WaitingStatusView: View {
    let pairCode: String
    var body: some View {
        VStack {
            Image(systemName: "clock")
            Text("Waiting for partner with code: \(pairCode)")
        }
    }
}

struct PairedStatusView: View {
    let partner: UserProfile
    var body: some View {
        VStack {
            Image(systemName: "person.2.fill")
            Text("Paired with: \(partner.name)")
        }
    }
}

struct FailedStatusView: View {
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
            Text("Pairing failed. Try again.")
        }
    }
}
