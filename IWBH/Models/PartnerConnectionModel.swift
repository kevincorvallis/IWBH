import Foundation
import SwiftUI
import CloudKit
import Combine

class PartnerConnectionModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var pairingStatus: PairingStatus = .unpaired
    @Published var pairCode: String = ""
    @Published var enteredPairCode: String = ""
    @Published var isGeneratingCode: Bool = false
    @Published var isPairing: Bool = false
    @Published var pairingError: String?
    @Published var showingPairCodeSheet: Bool = false
    @Published var showingEnterCodeSheet: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProfile()
        setupRealtimeUpdates()
    }
    
    // MARK: - Profile Management
    
    func createProfile(userID: String, name: String) {
        let profile = UserProfile(userID: userID, name: name)
        self.userProfile = profile
        saveProfile()
    }
    
    func updateProfile(_ profile: UserProfile) {
        self.userProfile = profile
        saveProfile()
        // TODO: Sync to CloudKit
    }
    
    private func saveProfile() {
        guard let profile = userProfile else { return }
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }
    
    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: "userProfile"),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return
        }
        self.userProfile = profile
        updatePairingStatus()
    }
    
    // MARK: - Pairing System
    
    func generatePairCode() {
        isGeneratingCode = true
        pairingError = nil
        
        // Generate a unique 6-digit code
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        self.pairCode = code
        
        // Update profile with pair code
        userProfile?.pairCode = code
        saveProfile()
        
        // TODO: Upload to CloudKit with expiration (15 minutes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isGeneratingCode = false
            self.pairingStatus = .waitingForPartner
            self.showingPairCodeSheet = true
        }
    }
    
    func enterPairCode(_ code: String) {
        isPairing = true
        pairingError = nil
        
        // Simulate pairing process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // TODO: Search CloudKit for matching pair code
            // For now, simulate successful pairing
            if code.count == 6 && code != self.pairCode {
                self.completePairing(partnerUserID: "partner_\(code)")
            } else {
                self.pairingError = "Invalid pair code. Please check and try again."
            }
            self.isPairing = false
        }
    }
    
    private func completePairing(partnerUserID: String) {
        // Create mock partner info
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
        userProfile?.pairCode = nil // Clear pair code after successful pairing
        
        saveProfile()
        pairingStatus = .paired
        showingEnterCodeSheet = false
        
        // TODO: Notify partner of successful pairing
        // TODO: Clear pair code from CloudKit
    }
    
    func unpair() {
        userProfile?.partnerId = nil
        userProfile?.partnerProfile = nil
        userProfile?.pairCode = nil
        saveProfile()
        pairingStatus = .unpaired
        pairCode = ""
        
        // TODO: Notify partner and update CloudKit
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
    
    // MARK: - Real-time Updates
    
    private func setupRealtimeUpdates() {
        // TODO: Set up CloudKit subscription for real-time partner updates
        // For now, simulate periodic updates
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updatePartnerStatus()
            }
            .store(in: &cancellables)
    }
    
    private func updatePartnerStatus() {
        // TODO: Fetch latest partner info from CloudKit
        guard var profile = userProfile,
              var _ = profile.partnerId else { return }
        
        // Simulate partner online status
        profile.partnerProfile?.isOnline = Bool.random()
        if !(profile.partnerProfile?.isOnline ?? false) {
            profile.partnerProfile?.lastSeen = Date().addingTimeInterval(-Double.random(in: 300...3600))
        }
        
        self.userProfile = profile
        saveProfile()
    }
    
    // MARK: - Utility Functions
    
    func formatLastSeen(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func isPartnerOnline() -> Bool {
        return userProfile?.partnerProfile?.isOnline ?? false
    }
}

// MARK: - CloudKit Extensions (TODO)

extension PartnerConnectionModel {
    // TODO: Implement CloudKit functionality
    // - Upload pair codes with expiration
    // - Search for matching pair codes
    // - Sync profile updates
    // - Real-time notifications
    // - Handle conflicts and errors
}
