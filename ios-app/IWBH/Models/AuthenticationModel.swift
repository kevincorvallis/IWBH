import Foundation
import SwiftUI
import AuthenticationServices
import FirebaseAuth

class AuthenticationModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userID: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var isGuest: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    init() {
        checkSignInStatus()
    }

    func checkSignInStatus() {
        if let user = Auth.auth().currentUser {
            self.userID = user.uid
            self.userName = user.displayName ?? ""
            self.userEmail = user.email ?? ""
            self.isSignedIn = true
            self.isGuest = false
        } else {
            let userID = UserDefaults.standard.string(forKey: "userID")
            let userName = UserDefaults.standard.string(forKey: "userName")
            let userEmail = UserDefaults.standard.string(forKey: "userEmail")
            let isGuestMode = UserDefaults.standard.bool(forKey: "isGuest")

            if let userID = userID, !userID.isEmpty {
                self.userID = userID
                self.userName = userName ?? ""
                self.userEmail = userEmail ?? ""
                self.isSignedIn = true
                self.isGuest = isGuestMode
            }
        }
    }

    // MARK: - Apple Sign In (Native Only)
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = ""

        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

                self.userID = userID
                self.userName = [fullName?.givenName, fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                self.userEmail = email ?? ""

                UserDefaults.standard.set(userID, forKey: "userID")
                UserDefaults.standard.set(self.userName, forKey: "userName")
                UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                UserDefaults.standard.set(false, forKey: "isGuest")

                self.isSignedIn = true
                self.isGuest = false
                self.isLoading = false
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    // MARK: - Continue as Guest
    func continueAsGuest() {
        self.userID = "guest-\(UUID().uuidString.prefix(8))"
        self.userName = "Guest"
        self.userEmail = ""
        self.isSignedIn = true
        self.isGuest = true

        UserDefaults.standard.set(self.userID, forKey: "userID")
        UserDefaults.standard.set(self.userName, forKey: "userName")
        UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
        UserDefaults.standard.set(true, forKey: "isGuest")
    }

    // MARK: - Firebase Email/Password Authentication
    func signUpWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else if let user = authResult?.user {
                    self.userID = user.uid
                    self.userEmail = user.email ?? ""
                    self.userName = user.displayName ?? ""
                    self.isSignedIn = true
                    self.isGuest = false
                    completion(true)
                }
            }
        }
    }

    func signInWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else if let user = authResult?.user {
                    self.userID = user.uid
                    self.userEmail = user.email ?? ""
                    self.userName = user.displayName ?? ""
                    self.isSignedIn = true
                    self.isGuest = false
                    completion(true)
                }
            }
        }
    }

    // MARK: - Forgot Password (Firebase only)
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    // MARK: - Logout
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }

        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "isGuest")

        self.userID = ""
        self.userName = ""
        self.userEmail = ""
        self.isSignedIn = false
        self.isGuest = false
        self.errorMessage = ""
    }

    // MARK: - Account Deletion
    func deleteAccount(feedback: String? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard !userID.isEmpty else {
            let error = NSError(domain: "AuthenticationModel", code: 401,
                               userInfo: [NSLocalizedDescriptionKey: "Not signed in"])
            errorMessage = "You must be signed in to delete your account"
            completion?(.failure(error))
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Call the ChatService to request account deletion
        ChatService.shared.requestAccountDeletion(userId: userID, feedback: feedback) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    // Store the grace period end date if needed for future reference
                    UserDefaults.standard.set(response.gracePeriodEndDate, forKey: "accountDeletionGracePeriod")
                    UserDefaults.standard.set(true, forKey: "accountDeletionInProgress")
                    
                    // Revoke access immediately
                    self.signOut()
                    
                    // Log successful deletion request
                    print("Account deletion requested successfully. Grace period ends on: \(response.gracePeriodEndDate)")
                    
                    completion?(.success(()))
                    
                case .failure(let error):
                    self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    completion?(.failure(error))
                }
            }
        }
    }
}
