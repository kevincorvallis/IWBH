import Foundation
import SwiftUI
import AuthenticationServices

class AuthenticationModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userID: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    init() {
        checkSignInStatus()
    }
    
    func checkSignInStatus() {
        // Check if user is already signed in
        let userID = UserDefaults.standard.string(forKey: "userID")
        let userName = UserDefaults.standard.string(forKey: "userName")
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        
        if let userID = userID, !userID.isEmpty {
            self.userID = userID
            self.userName = userName ?? ""
            self.userEmail = userEmail ?? ""
            self.isSignedIn = true
        }
    }
    
    func signIn(with result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = ""
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Get user information
                let userID = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // Store user information
                self.userID = userID
                self.userName = [fullName?.givenName, fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                self.userEmail = email ?? ""
                
                // Save to UserDefaults
                UserDefaults.standard.set(userID, forKey: "userID")
                UserDefaults.standard.set(self.userName, forKey: "userName")
                UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                
                self.isSignedIn = true
                self.isLoading = false
            }
            
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func signOut() {
        // Clear user data
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        
        // Reset state
        self.userID = ""
        self.userName = ""
        self.userEmail = ""
        self.isSignedIn = false
        self.errorMessage = ""
    }
}
