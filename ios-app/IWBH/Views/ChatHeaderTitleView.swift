//
//  ChatHeaderTitleView.swift
//  IWBH
//
//  Created by Kevin Lee on 6/8/25.
//

import SwiftUI

struct ChatHeaderTitleView: View {
    @ObservedObject var chatService: ChatService
    
    var body: some View {
        HStack {
            Spacer()
            Text("Nova")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.25), value: chatService.chatMessages.count)
    }
}
