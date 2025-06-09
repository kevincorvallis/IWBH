import SwiftUI

struct ChatMessagesView: View {
    @ObservedObject var chatService: ChatService
    @Binding var isScrollToBottomNeeded: Bool

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatService.chatMessages) { message in
                        ChatBubble(message: message)
                    }
                    Color.clear
                        .frame(height: 1)
                        .id("bottomID")
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .onChange(of: chatService.chatMessages.count) {
                withAnimation {
                    scrollView.scrollTo("bottomID", anchor: .bottom)
                }
            }
            .onChange(of: isScrollToBottomNeeded) {
                if isScrollToBottomNeeded {
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                        isScrollToBottomNeeded = false
                    }
                }
            }
        }
    }
}
