import SwiftUI
import AuthenticationServices

struct LoginButtonsView: View {
    @Binding var isEmailValid: Bool
    @Binding var isPasswordValid: Bool
    @Binding var isLoading: Bool
    let signIn: () -> Void
    let signUp: () -> Void
    let authModel: AuthenticationModel
    @Environment(\.hapticFeedback) private var hapticFeedback
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: signIn) {
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: isEmailValid && isPasswordValid && !isLoading))
            .disabled(!isEmailValid || !isPasswordValid || isLoading)
            
            Button(action: signUp) {
                Text("Create Account")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(SecondaryButtonStyle(isEnabled: isEmailValid && isPasswordValid && !isLoading))
            .disabled(!isEmailValid || !isPasswordValid || isLoading)
            
            HStack {
                Rectangle().fill(Color(.systemGray4)).frame(height: 1)
                Text("OR")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                Rectangle().fill(Color(.systemGray4)).frame(height: 1)
            }
            .padding(.vertical, 8)
            
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    withAnimation { isLoading = true }
                    hapticFeedback.impact(.medium)
                    authModel.handleAppleSignIn(result)
                    withAnimation { isLoading = false }
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .cornerRadius(12)
            
            Text("Your data stays private and secure on your device")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
}
