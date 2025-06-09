//
//  SaveConversationSheet.swift
//  IWBH
//
//  Created by Kevin Lee on 6/8/25.
//

import SwiftUI
struct SaveConversationSheet: View {
    @ObservedObject var chatService: ChatService
    @Binding var conversationName: String
    @Binding var showingSaveDialog: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Save Conversation")) {
                    TextField("Enter a name for this conversation", text: $conversationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                    
                    Button("Save") {
                        if !conversationName.isEmpty {
                            let preview = chatService.chatMessages.last?.isUser == true ?
                                          chatService.chatMessages.last?.text ?? "" :
                                          chatService.chatMessages.dropLast().last?.text ?? ""
                            
                            let chatPreview = ChatPreview(
                                title: conversationName,
                                preview: preview,
                                messages: chatService.chatMessages
                            )
                            
                            chatService.saveConversation(chatPreview)
                            conversationName = ""
                            showingSaveDialog = false
                        }
                    }
                    .disabled(conversationName.isEmpty)
                }
            }
            .navigationTitle("Save Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingSaveDialog = false }
                }
            }
        }
    }
}
