import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onLogout: () -> Void
    let onContinueAsGuest: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 16)

            Button(action: {
                onLogout()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                    Text("Log Out").fontWeight(.semibold)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 2))
            }

            Button(action: {
                onContinueAsGuest()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "person.fill.questionmark")
                    Text("Continue as Guest").fontWeight(.semibold)
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2))
            }

            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Close").fontWeight(.semibold)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding()
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}
