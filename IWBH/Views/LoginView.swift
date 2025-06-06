import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authModel: AuthenticationModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Logo/Title
            VStack(spacing: 20) {
                Text("IWBH")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("I Wanna Be Held")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Track your peaceful days together")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Features Preview
            VStack(spacing: 20) {
                FeatureRow(icon: "calendar", title: "Track Peaceful Days", description: "Count consecutive days without fighting")
                FeatureRow(icon: "target", title: "Relationship Goals", description: "Achieve milestones together")
                FeatureRow(icon: "heart.fill", title: "Peace Activities", description: "Discover ways to strengthen your bond")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Sign In Button
            VStack(spacing: 15) {
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        // Handle result - this will be managed by AuthenticationModel
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                
                Text("Your data stays private and secure on your device")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authModel: AuthenticationModel())
    }
}
