import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authModel: AuthenticationModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
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
            
            VStack(spacing: 15) {
                // Email / Password Fields
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Sign In") {
                        authModel.signInWithEmail(email: email, password: password) { success in }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Sign Up") {
                        authModel.signUpWithEmail(email: email, password: password) { success in }
                    }
                    .buttonStyle(.bordered)
                }

                // Apple Sign In Button
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        authModel.handleAppleSignIn(result)
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
            
            // Show error messages, if any
            if !authModel.errorMessage.isEmpty {
                Text(authModel.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

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
