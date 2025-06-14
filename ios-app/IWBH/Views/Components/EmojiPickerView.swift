import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    let emojiOptions: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(emojiOptions, id: \.self) { emoji in
                    Button(action: {
                        selectedEmoji = emoji
                        dismiss()
                    }) {
                        Text(emoji)
                            .font(.system(size: 40))
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(selectedEmoji == emoji ?
                                          Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
                                    .stroke(selectedEmoji == emoji ?
                                           Color.pink : Color.clear, lineWidth: 2)
                            )
                    }
                }        }
        .padding()
        .navigationTitle("Choose Emoji")
        .toolbar {
            ToolbarItem {
                Button("Done") { dismiss() }
            }
        }
        }
    }
}
