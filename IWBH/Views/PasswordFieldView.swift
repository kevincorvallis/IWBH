import SwiftUI
import UIKit

struct PasswordFieldView: View {
    @Binding var password: String
    @Binding var isPasswordValid: Bool
    @Binding var showPassword: Bool
    @FocusState.Binding var focusedField: LoginFieldType?
    let validatePassword: () -> Void
    let signIn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                
                if showPassword {
                    TextField("Password", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onChange(of: password) { validatePassword() }
                        .accessibilityLabel("Password field, visible")
                } else {
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signIn)
                        .onChange(of: password) { validatePassword() }
                        .accessibilityLabel("Password field, hidden")
                }
                
                Button(action: { withAnimation(.spring(response: 0.3)) { showPassword.toggle() } }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .accessibilityLabel(showPassword ? "Hide password" : "Show password")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: focusedField == .password ? .accentColor.opacity(0.3) : .clear, radius: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focusedField == .password ? Color.accentColor : Color.clear, lineWidth: 1)
            )
            
            if !password.isEmpty && !isPasswordValid {
                Text("Password must be at least 8 characters")
                    .font(.caption)
                    .foregroundColor(.red)
            } else if isPasswordValid && !password.isEmpty {
                Text("Password meets requirements")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
}
