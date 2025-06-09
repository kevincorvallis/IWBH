import SwiftUI

struct PreviousChatsView: View {
    @ObservedObject var chatService: ChatService
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if chatService.previousChats.isEmpty {
                    EmptyChatsView()
                } else {
                    ChatsListView(
                        chats: filteredChats,
                        chatService: chatService,
                        searchText: $searchText,
                        presentationMode: presentationMode
                    )
                }
            }
            .navigationTitle("Previous Chats")
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
    
    private var filteredChats: [ChatPreview] {
        if searchText.isEmpty {
            return chatService.previousChats
        } else {
            return chatService.previousChats.filter { chat in
                chat.title.localizedCaseInsensitiveContains(searchText) ||
                chat.preview.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// Empty state view
struct EmptyChatsView: View {
    var body: some View {
        ContentUnavailableView(
            "No Previous Chats",
            systemImage: "bubble.left.and.bubble.right",
            description: Text("Your past conversations will appear here")
        )
    }
}

// List of chats view
struct ChatsListView: View {
    let chats: [ChatPreview]
    let chatService: ChatService
    @Binding var searchText: String
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            ForEach(chats) { chat in
                ChatRowView(
                    chat: chat,
                    chatService: chatService,
                    presentationMode: presentationMode
                )
            }
        }
        .searchable(text: $searchText, prompt: "Search conversations")
        .listStyle(.insetGrouped)
    }
}

// Individual chat row
struct ChatRowView: View {
    let chat: ChatPreview
    let chatService: ChatService
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            // Load the selected chat
            chatService.loadChat(chat)
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(chat.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(chat.preview)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(formatDate(chat.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .swipeActions {
            Button(role: .destructive) {
                // Delete the chat
                withAnimation {
                    chatService.deleteChat(chat)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                // Rename action
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Preview for SwiftUI Canvas
struct PreviousChatsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousChatsView(chatService: ChatService())
    }
}
