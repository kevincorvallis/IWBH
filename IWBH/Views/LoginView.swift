import SwiftUI
import UIKit
import AuthenticationServices
import Combine

struct LoginView: View {
    @ObservedObject var authModel: AuthenticationModel
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var showPassword = false
    @State private var isLoading = false
    @FocusState private var focusedField: LoginFieldType?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.hapticFeedback) private var hapticFeedback

    @State private var logoOffset: CGFloat = -100
    @State private var formOpacity: Double = 0
    @State private var formOffset: CGFloat = 30
    @State private var logoScale: CGFloat = 0.8

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 36) {
                    LogoHeaderView(
                        logoScale: $logoScale,
                        logoOffset: $logoOffset,
                        formOpacity: $formOpacity
                    )
                    .padding(.top, geometry.safeAreaInsets.top + 40)

                    VStack(spacing: 20) {
                        EmailFieldView(
                            email: $email,
                            isEmailValid: $isEmailValid,
                            focusedField: $focusedField,
                            validateEmail: validateEmail
                        )

                        PasswordFieldView(
                            password: $password,
                            isPasswordValid: $isPasswordValid,
                            showPassword: $showPassword,
                            focusedField: $focusedField,
                            validatePassword: validatePassword,
                            signIn: signIn
                        )

                        LoginButtonsView(
                            isEmailValid: $isEmailValid,
                            isPasswordValid: $isPasswordValid,
                            isLoading: $isLoading,
                            signIn: signIn,
                            signUp: signUp,
                            authModel: authModel
                        )
                    }
                    .padding(.horizontal)
                    .opacity(formOpacity)
                    .offset(y: formOffset)

                    ErrorMessageView(
                        errorMessage: authModel.errorMessage,
                        clearError: { authModel.errorMessage = "" }
                    )
                }
                .padding(.horizontal)
                .frame(minHeight: geometry.size.height)
            }
            .background(
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color(.systemBackground),
                            Color.accentColor.opacity(colorScheme == .dark ? 0.15 : 0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    GeometryReader { geo in
                        ForEach(0..<10) { _ in
                            Circle()
                                .fill(Color.accentColor.opacity(0.05))
                                .frame(width: CGFloat.random(in: 50...200))
                                .position(
                                    x: CGFloat.random(in: 0...geo.size.width),
                                    y: CGFloat.random(in: 0...geo.size.height)
                                )
                        }
                    }
                    .ignoresSafeArea()
                }
            )
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3)) {
                    logoScale = 1.0
                    logoOffset = 0
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                    formOpacity = 1
                    formOffset = 0
                }
            }
            .onTapGesture { focusedField = nil }
        }
    }

    private func validateEmail() {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let previousState = isEmailValid
        isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        if previousState != isEmailValid && !email.isEmpty {
            hapticFeedback.notificationOccurred(isEmailValid ? .success : .warning)
        }
    }

    private func validatePassword() {
        let previousState = isPasswordValid
        isPasswordValid = password.count >= 8
        if previousState != isPasswordValid && !password.isEmpty {
            hapticFeedback.notificationOccurred(isPasswordValid ? .success : .warning)
        }
    }

    private func signIn() {
        guard isEmailValid && isPasswordValid else { return }
        focusedField = nil
        hapticFeedback.notificationOccurred(.success)
        withAnimation { isLoading = true }
        authModel.signInWithEmail(email: email, password: password) { success in
            withAnimation { isLoading = false }
            if !success { hapticFeedback.notificationOccurred(.error) }
        }
    }

    private func signUp() {
        guard isEmailValid && isPasswordValid else { return }
        focusedField = nil
        hapticFeedback.notificationOccurred(.success)
        withAnimation { isLoading = true }
        authModel.signUpWithEmail(email: email, password: password) { success in
            withAnimation { isLoading = false }
            if !success { hapticFeedback.notificationOccurred(.error) }
        }
    }
}

// MARK: - Button Styles (can remain if used by subviews)
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.accentColor : Color.accentColor.opacity(0.6))
                    .shadow(color: isEnabled ? Color.accentColor.opacity(0.4) : .clear, radius: 6, x: 0, y: 3)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .opacity(configuration.isPressed && isEnabled ? 0.9 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEnabled ? Color.accentColor : Color.accentColor.opacity(0.6), lineWidth: 1.5)
            )
            .foregroundColor(isEnabled ? .accentColor : .accentColor.opacity(0.6))
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .opacity(configuration.isPressed && isEnabled ? 0.9 : 1)
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(authModel: AuthenticationModel())
                .preferredColorScheme(.light)
                .environment(\.hapticFeedback, HapticFeedback.shared)
            LoginView(authModel: AuthenticationModel())
                .preferredColorScheme(.dark)
                .environment(\.hapticFeedback, HapticFeedback.shared)
        }
    }
}

struct EmailFieldView: View {
   @Binding var email: String
   @Binding var isEmailValid: Bool
   @FocusState.Binding var focusedField: LoginFieldType?
   let validateEmail: () -> Void
   
   var body: some View {
       VStack(alignment: .leading, spacing: 4) {
           HStack {
               Image(systemName: "envelope")
                   .foregroundColor(.secondary)
                   .accessibilityHidden(true)
               
               TextField("Email", text: $email)
                   .keyboardType(.emailAddress)
                   .autocapitalization(.none)
                   .autocorrectionDisabled()
                   .textContentType(.emailAddress)
                   .onChange(of: email) { validateEmail() }
                   .focused($focusedField, equals: .email)
                   .submitLabel(.next)
                   .onSubmit { focusedField = .password }
                   .accessibilityLabel("Email address")
                   .accessibilityHint("Enter your email address")
               
               if !email.isEmpty {
                   Image(systemName: isEmailValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                       .foregroundColor(isEmailValid ? .green : .red)
                       .opacity(email.isEmpty ? 0 : 1)
                       .animation(.spring(response: 0.3), value: isEmailValid)
                       .accessibilityHidden(true)
               }
           }
           .padding()
           .background(
               RoundedRectangle(cornerRadius: 12)
                   .fill(Color(.secondarySystemBackground))
                   .shadow(color: focusedField == .email ? .accentColor.opacity(0.3) : .clear, radius: 4)
           )
           .overlay(
               RoundedRectangle(cornerRadius: 12)
                   .stroke(focusedField == .email ? Color.accentColor : Color.clear, lineWidth: 1)
           )
           
           if !email.isEmpty && !isEmailValid {
               Text("Please enter a valid email address")
                   .font(.caption)
                   .foregroundColor(.red)
           } else if isEmailValid && !email.isEmpty {
               Text("Valid email format")
                   .font(.caption)
                   .foregroundColor(.green)
           }
       }
   }
}

