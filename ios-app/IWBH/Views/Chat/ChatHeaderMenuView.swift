//
//  ChatHeaderMenuView.swift
//  IWBH
//
//  Created by Kevin Lee on 6/8/25.
//
import SwiftUI
struct ChatHeaderMenuView: View {
    @ObservedObject var chatService: ChatService
    @Binding var showingPreviousChats: Bool
    @Binding var showingSettings: Bool
    @Binding var showingSuggestions: Bool
    @Binding var showingSaveDialog: Bool
    @Binding var conversationName: String
    @Binding var showingShareSheet: Bool
    @Binding var shareItems: [Any]
    
    var body: some View {
        HStack {
            Spacer()
            Menu {
                Section(header: Text("Chat Options")) {
                    Button {
                        showingPreviousChats = true
                    } label: {
                        Label("Previous Chats", systemImage: "clock.arrow.circlepath")
                    }
                    Button {
                        withAnimation { chatService.clearChatHistory() }
                    } label: {
                        Label("Start New Chat", systemImage: "plus.bubble")
                    }
                    Button {
                        showingSuggestions = true
                    } label: {
                        Label("Conversation Starters", systemImage: "lightbulb")
                    }
                }
                
                Section(header: Text("Tools")) {
                    Button { showingSaveDialog = true } label: {
                        Label("Save Conversation", systemImage: "square.and.arrow.down")
                    }
                    Button {
                        let formatted = chatService.chatMessages.map { $0.isUser ? "You: \($0.text)" : "Nova: \($0.text)" }.joined(separator: "\n\n")
                        shareItems = ["Conversation with Nova:\n\n\(formatted)"]
                        showingShareSheet = true
                    } label: {
                        Label("Share Conversation", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section(header: Text("Settings")) {
                    Button { showingSettings = true } label: {
                        Label("Chat Settings", systemImage: "gear")
                    }
                }
                
                Divider()
                
                Button(role: .destructive) {
                    withAnimation { chatService.clearChatHistory() }
                } label: {
                    Label("Clear History", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(Color.pink)
                    .padding(.horizontal)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: chatService.chatMessages.count)
    }
}
