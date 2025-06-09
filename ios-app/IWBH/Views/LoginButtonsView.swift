import SwiftUI
import AuthenticationServices

struct LoginButtonsView: View {
    @Binding var isEmailValid: Bool
    @Binding var isPasswordValid: Bool
    @Binding var isLoading: Bool
    @Binding var email: String
    @State private var showingForgotPassword = false
    @State private var resetEmailSent = false
    @State private var resetPasswordEmail = ""
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
            
            HStack {
                Button(action: {
                    resetPasswordEmail = email // Pre-populate with current email if available
                    showingForgotPassword = true
                }) {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                }
                .padding(.vertical, 5)
                
                Spacer()
                
                Button(action: signUp) {
                    Text("Create Account")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                }
                .padding(.vertical, 5)
            }
            
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
        .sheet(isPresented: $showingForgotPassword) {
            PasswordResetView(
                email: $resetPasswordEmail,
                isShowing: $showingForgotPassword,
                resetSuccess: $resetEmailSent,
                authModel: authModel
            )
        }
        .alert(isPresented: $resetEmailSent) {
            Alert(
                title: Text("Check Your Email"),
                message: Text("If an account exists with \(resetPasswordEmail), a password reset link has been sent."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct PasswordResetView: View {
    @Binding var email: String
    @Binding var isShowing: Bool
    @Binding var resetSuccess: Bool
    @State private var isEmailValid = false
    let authModel: AuthenticationModel
    @Environment(\.hapticFeedback) private var hapticFeedback
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Your Password")
                    .font(.headline)
                    .padding(.top, 20)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Your Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    .onChange(of: email) { newValue, transaction in
                        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
                        isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: newValue)
                    }
                
                Button(action: {
                    if isEmailValid {
                        hapticFeedback.impact(.medium)
                        authModel.resetPassword(email: email) { success in
                            resetSuccess = true
                            isShowing = false
                        }
                    }
                }) {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isEmailValid ? Color.accentColor : Color.accentColor.opacity(0.6))
                        )
                        .padding(.horizontal)
                }
                .disabled(!isEmailValid)
                
                Spacer()
            }
            .navigationBarItems(
                trailing: Button("Cancel") { isShowing = false }
            )
        }
    }
}
