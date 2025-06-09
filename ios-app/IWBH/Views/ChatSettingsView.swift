import SwiftUI

struct ChatSettingsView: View {
    @ObservedObject var chatService: ChatService
    @Environment(\.presentationMode) var presentationMode
    
    // These would be stored in UserDefaults in a real implementation
    @State private var personalizedResponses = true
    @State private var showTypingIndicator = true
    @State private var autoSaveChats = true
    @State private var selectedTheme = "Default"
    @State private var selectedLanguage = "English"
    
    private let themeOptions = ["Default", "Light", "Dark", "System"]
    private let languageOptions = ["English", "Spanish", "French", "German", "Chinese"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chat Experience")) {
                    Toggle("Personalized Responses", isOn: $personalizedResponses)
                    Toggle("Show Typing Indicator", isOn: $showTypingIndicator)
                    Toggle("Auto-save Conversations", isOn: $autoSaveChats)
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(themeOptions, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languageOptions, id: \.self) { language in
                            Text(language)
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Chat Reminders", isOn: .constant(true))
                    Toggle("New Feature Alerts", isOn: .constant(true))
                }
                
                Section(header: Text("Data & Privacy")) {
                    Button(action: {
                        // Export chat data functionality
                    }) {
                        Label("Export Chat Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // This would show a confirmation dialog before clearing
                        withAnimation {
                            chatService.clearChatHistory()
                        }
                    }) {
                        Label("Delete All Chats", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        // Open help center
                    }) {
                        Text("Help Center")
                    }
                    
                    Button(action: {
                        // Send feedback
                    }) {
                        Text("Send Feedback")
                    }
                }
            }
            .navigationTitle("Chat Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Save settings before dismissing
                        // This would persist settings to UserDefaults in a real app
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}