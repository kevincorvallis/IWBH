//
//  ChatHeaderSubtitleView.swift
//  IWBH
//
//  Created by Kevin Lee on 6/8/25.
//

import SwiftUI
struct ChatHeaderSubtitleView: View {
    @ObservedObject var chatService: ChatService
    
    var body: some View {
        Text("Ask for advice or share your thoughts")
            .font(.caption)
            .foregroundColor(.secondary)
            .accessibilityLabel("Ask for advice or share your thoughts with Nova")
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: chatService.chatMessages.count)
    }
}

