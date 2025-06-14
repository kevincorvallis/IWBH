import SwiftUI

struct ErrorMessageView: View {
    let errorMessage: String
    let clearError: () -> Void
    @Environment(\.hapticFeedback) private var hapticFeedback
    
    var body: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                .padding(.horizontal)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                .onAppear {
                    hapticFeedback.notificationOccurred(.error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation { clearError() }
                    }
                }
                .accessibilityLabel("Error: \(errorMessage)")
        }
    }
}
