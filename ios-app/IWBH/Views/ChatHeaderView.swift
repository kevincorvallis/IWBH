import SwiftUI

struct ChatHeaderView: View {
    @ObservedObject var chatService: ChatService
    @State private var showingPreviousChats = false
    @State private var showingSettings = false
    @State private var showingSuggestions = false
    @State private var showingSaveDialog = false
    @State private var conversationName = ""
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        VStack(spacing: 4) {
            ChatHeaderTitleView(chatService: chatService)
            ChatHeaderSubtitleView(chatService: chatService)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(BlurView(style: .systemMaterial))
        .shadow(color: Color(.systemGray5), radius: 2)
        .overlay(
            ChatHeaderMenuView(
                chatService: chatService,
                showingPreviousChats: $showingPreviousChats,
                showingSettings: $showingSettings,
                showingSuggestions: $showingSuggestions,
                showingSaveDialog: $showingSaveDialog,
                conversationName: $conversationName,
                showingShareSheet: $showingShareSheet,
                shareItems: $shareItems
            )
        )
        .sheet(isPresented: $showingPreviousChats) {
            PreviousChatsView(chatService: chatService)
        }
        .sheet(isPresented: $showingSettings) {
            ChatSettingsView(chatService: chatService)
        }
        .sheet(isPresented: $showingSuggestions) {
            ConversationStartersView(chatService: chatService)
        }
        .sheet(isPresented: $showingSaveDialog) {
            SaveConversationSheet(
                chatService: chatService,
                conversationName: $conversationName,
                showingSaveDialog: $showingSaveDialog
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
}
