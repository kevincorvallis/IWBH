import SwiftUI

struct AccountDeletionView: View {
    let onConfirm: (String?) -> Void
    let onCancel: () -> Void
    
    @State private var feedback: String = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Warning Header
                    VStack(spacing: 16) {
                        Text("⚠️")
                            .font(.system(size: 60))
                        
                        Text("Delete Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("This action cannot be undone")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 20)
                    
                    // Warning Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What happens when you delete your account:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            WarningItem(text: "All your profile data will be permanently deleted")
                            WarningItem(text: "Your chat history will be removed")
                            WarningItem(text: "Your partner connection will be severed")
                            WarningItem(text: "This action cannot be reversed")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.05))
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Optional Feedback
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Help us improve (optional)")
                            .font(.headline)
                        
                        Text("Let us know why you're leaving")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $feedback)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingConfirmation = true
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Delete My Account")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        })
                        
                        Button(action: onCancel) {
                            HStack {
                                Spacer()
                                Text("Cancel")
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
        .alert("Final Confirmation", isPresented: $showingConfirmation, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                onConfirm(feedback.isEmpty ? nil : feedback)
            }
        }, message: {
            Text("Are you absolutely sure you want to delete your account? This action cannot be undone.")
        })
    }
}

struct WarningItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.red)
                .fontWeight(.bold)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
