import SwiftUI

struct ConversationStartersView: View {
    @ObservedObject var chatService: ChatService
    @Environment(\.presentationMode) var presentationMode
    
    // Sample conversation starters organized by category
    private let categories = [
        "Relationship Advice": [
            "How do I better communicate with my partner about our future?",
            "What are some ways to spice up our relationship?",
            "How do I handle jealousy in a healthy way?",
            "What are good strategies for resolving conflicts?"
        ],
        "Dating Tips": [
            "How do I make a good impression on a first date?",
            "What are some creative date ideas?",
            "How do I know if someone is right for me?",
            "How do I navigate the early stages of dating?"
        ],
        "Personal Growth": [
            "How can I become more confident in my relationships?",
            "How do I set healthy boundaries?",
            "What can I do to improve my emotional intelligence?",
            "How do I overcome fears of vulnerability?"
        ],
        "Communication": [
            "How can I express my needs better?",
            "What are effective ways to have difficult conversations?",
            "How do I become a better listener?",
            "How do I communicate during conflict without making things worse?"
        ]
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(categories.keys.sorted()), id: \.self) { category in
                    Section(header: Text(category)) {
                        if let starters = categories[category] {
                            ForEach(starters, id: \.self) { starter in
                                Button(action: {
                                    // Send this starter as a message
                                    useSuggestion(starter)
                                }) {
                                    HStack {
                                        Text(starter)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.circle.fill")
                                            .foregroundColor(Color.pink)
                                            .imageScale(.medium)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Conversation Starters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func useSuggestion(_ suggestion: String) {
        // This would send the suggestion as a user message
        // In a real implementation, this would call the chatService to send the message
        
        // For demonstration purposes, we'll just dismiss the sheet
        // In a real app, you would:
        // 1. Send the message via chatService
        // 2. Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}