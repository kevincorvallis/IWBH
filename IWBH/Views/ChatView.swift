import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject private var chatService = ChatService()
    @ObservedObject var authModel: AuthenticationModel
    @State private var message = ""
    @State private var isScrollToBottomNeeded = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingAttachmentOptions = false
    @State private var imageAttachmentItem: PhotosPickerItem?
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            // Subtle background for seamless look
            LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // Back button removed as requested
                ChatHeaderView(chatService: chatService)
                Divider().opacity(0.15)
                ChatMessagesView(chatService: chatService, isScrollToBottomNeeded: $isScrollToBottomNeeded)
                    .background(Color.clear)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.hideKeyboard()
                    }
                // Image preview before sending
                // This block shows a preview of the selected image above the input area, so users can see what they're about to send
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.horizontal, 8)
                        .frame(maxHeight: 180)
                        .transition(.opacity)
                }
                ChatInputAreaView(
                    chatService: chatService,
                    message: $message,
                    selectedImage: $selectedImage,
                    showingAttachmentOptions: $showingAttachmentOptions,
                    sendMessage: sendMessage,
                    isMessageReadyToSend: isMessageReadyToSend
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding([.horizontal, .bottom], 8)
                .shadow(color: Color(.systemGray4).opacity(0.15), radius: 6, y: 2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: chatService.chatMessages.count)
        .alert(item: Binding<ChatAlertItem?>(
            get: {
                if let error = chatService.error {
                    return ChatAlertItem(message: error)
                }
                return nil
            },
            set: { _ in chatService.error = nil }
        )) { alertItem in
            Alert(
                title: Text("Error"),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .photosPicker(
            isPresented: $showingAttachmentOptions,
            selection: $imageAttachmentItem,
            matching: .images
        )
        .onChange(of: imageAttachmentItem) { newValue, _ in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
        .onAppear {
            // Add welcome message if it's the first time
            if chatService.chatMessages.isEmpty {
                let welcomeMessage = ChatMessage(
                    id: UUID().uuidString,
                    isUser: false,
                    text: "Hi there! I'm your dating coach. How can I help with your relationship today?",
                    timestamp: Date()
                )
                chatService.chatMessages.append(welcomeMessage)
                chatService.saveMessagesToStorage()
            }
            // Request to scroll to bottom
            isScrollToBottomNeeded = true
        }
    }
    
    private var isMessageReadyToSend: Bool {
        (!message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil) && !chatService.isLoading
    }
    
    private func sendMessage() {
        guard isMessageReadyToSend else { return }
        let userMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        message = ""
        isScrollToBottomNeeded = true
        // Prepare the image data if available
        var imageData: Data?
        var fileName: String?
        if let image = selectedImage {
            imageData = image.jpegData(compressionQuality: 0.7)
            fileName = "image_\(Date().timeIntervalSince1970).jpg"
            selectedImage = nil // Clear the preview after sending
        }
        // Call the chat service
        chatService.sendMessage(
            userId: authModel.userID,
            message: userMessage.isEmpty ? "Looking at this image..." : userMessage,
            fileData: imageData,
            fileName: fileName
        ) { result in
            switch result {
            case .success(_):
                // Add haptic feedback for message received
                sendHapticSuccess()
                
            case .failure:
                // Error is handled through the published property in chatService
                sendHapticError()
            }
        }
    }
}

private func sendHapticSuccess() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

private func sendHapticError() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}

struct ChatAlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct ChatBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme
    @State private var isImageLoaded = false
    @State private var loadedImage: UIImage?
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Show file attachment if available
                if let fileUrl = message.fileUrl, fileUrl.hasSuffix(".jpg") || fileUrl.hasSuffix(".jpeg") || fileUrl.hasSuffix(".png") {
                    Group {
                        if let image = loadedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                        } else {
                            ProgressView()
                                .frame(width: 200, height: 150)
                        }
                    }
                    .onAppear {
                        loadImage(from: fileUrl)
                    }
                }
                
                if !message.text.isEmpty || message.isUploading {
                    Text(message.isUploading ? "Uploading..." : message.text)
                        .padding(12)
                        .background(
                            message.isUser
                            ? Color.pink
                            : (colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                        )
                        .foregroundColor(message.isUser ? .white : .primary)
                        .cornerRadius(18)
                        .cornerRadius(message.isUser ? 18 : 2, corner: .topLeft)
                        .cornerRadius(message.isUser ? 2 : 18, corner: .topRight)
                        .overlay(
                            message.isUploading ?
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(6)
                            : nil
                        )
                }
                
                // Theme tags row
                if let tags = message.themeTags, !tags.isEmpty, !message.isUser {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag.capitalized)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.pink.opacity(0.2))
                                    .foregroundColor(.pink)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .frame(height: 24)
                }
                
                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 270, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImage = image
                    self.isImageLoaded = true
                }
            }
        }.resume()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corner: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corner: corner))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corner: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corner,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
