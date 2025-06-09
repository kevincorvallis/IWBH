import SwiftUI

struct EnterPairCodeView: View {
    @State private var pairCode = ""
    @FocusState private var isInputFocused: Bool
    let onSubmit: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Text("Enter Partner's Code")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Ask your partner to generate a pairing code in their profile and enter it below to connect.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    TextField("", text: $pairCode)
                        .keyboardType(.numberPad)
                        .focused($isInputFocused)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .onChange(of: pairCode) { oldValue, newValue in            
                            if newValue.count > 6 {
                                    pairCode = String(newValue.prefix(6))
                                }
                            
                            // Only allow digits
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                pairCode = filtered
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("Enter the 6-digit code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    if pairCode.count == 6 {
                        onSubmit(pairCode)
                    }
                }) {
                    Text("Connect")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(pairCode.count == 6 ? Color.blue : Color.gray)
                        )
                }
                .disabled(pairCode.count != 6)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInputFocused = true
                }
            }
        }
    }
}

struct EnterPairCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPairCodeView(
            onSubmit: { _ in },
            onCancel: { }
        )
    }
}
