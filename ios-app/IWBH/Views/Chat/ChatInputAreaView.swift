import SwiftUI

struct ChatInputAreaView: View {
    @ObservedObject var chatService: ChatService
    @Binding var message: String
    @Binding var selectedImage: UIImage?
    @Binding var showingAttachmentOptions: Bool
    let sendMessage: () -> Void
    let isMessageReadyToSend: Bool

    var body: some View {
        VStack(spacing: 8) {
            if chatService.isLoading {
                HStack(spacing: 4) {
                    Text("Dating Coach is typing")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.pink.opacity(0.7))
                            .frame(width: 5, height: 5)
                            .offset(y: index % 2 == 0 ? -2 : 2)
                            .animation(Animation.easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.2), value: index)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }

            if let image = selectedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .padding(.leading)

                    Text("Image attached")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button { selectedImage = nil } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 4)
                .background(Color(.systemGray6).opacity(0.5))
            }

            HStack(alignment: .bottom) {
                Button { showingAttachmentOptions = true } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
                .disabled(chatService.isLoading)

                TextField("Type a message...", text: $message, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)
                    .disabled(chatService.isLoading)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(isMessageReadyToSend ? .pink : .gray)
                }
                .disabled(!isMessageReadyToSend)
                .padding(.trailing, 8)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .shadow(color: Color(.systemGray5), radius: 5, y: -2)
    }
}
