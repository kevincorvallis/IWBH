import Foundation
import Combine
import SwiftUI

class ChatService: ObservableObject {
    static let shared = ChatService()
    
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var chatMessages: [ChatMessage] = []
    @Published var relationshipContext: RelationshipContext?
    @Published var previousChats: [ChatPreview] = []
    
    private let relationshipContextKey = "storedRelationshipContext"
    private let apiUrl = "https://ww5yu32db2.execute-api.us-west-2.amazonaws.com/prod/chat"
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "storedChatMessages"
    private let savedChatsKey = "savedConversations"

    init() {
        loadMessagesFromStorage()
        loadRelationshipContext()
        loadSavedConversations()
    }

    func sendMessage(
        userId: String,
        message: String,
        sharedWithPartner: Bool = false,
        fileData: Data? = nil,
        fileName: String? = nil,
        relationshipContext: RelationshipContext? = nil,
        completion: @escaping (Result<AIResponse, Error>) -> Void
    ) {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(ChatError.emptyMessage))
            return
        }

        isLoading = true
        error = nil

        let localMessage = ChatMessage(
            id: UUID().uuidString,
            isUser: true,
            text: message,
            timestamp: Date(),
            isUploading: fileData != nil
        )

        self.chatMessages.append(localMessage)
        saveMessagesToStorage()

        let requestObj = ChatRequest(
            userId: userId,
            message: message,
            sharedWithPartner: sharedWithPartner,
            fileData: fileData?.base64EncodedString(),
            fileName: fileName,
            relationshipContext: relationshipContext
        )
        

        guard let url = URL(string: apiUrl) else {
            isLoading = false
            error = "Invalid URL"
            completion(.failure(ChatError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestObj)
            request.httpBody = jsonData

            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw ChatError.invalidResponse
                    }

                    if let responseStr = String(data: data, encoding: .utf8) {
                        print("Response (\(httpResponse.statusCode)): \(responseStr)")
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        if let errorMessage = String(data: data, encoding: .utf8) {
                            throw ChatError.serverError(message: "Server error: \(errorMessage)")
                        } else {
                            throw ChatError.serverError(message: "Server error: \(httpResponse.statusCode)")
                        }
                    }

                    return data
                }
                .decode(type: AIResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completionStatus in
                        self?.isLoading = false
                        switch completionStatus {
                        case .finished: break
                        case .failure(let error):
                            self?.error = error.localizedDescription
                            completion(.failure(error))
                        }
                    },
                    receiveValue: { [weak self] response in
                        if let fileUrl = response.fileUrl,
                           let index = self?.chatMessages.firstIndex(where: { $0.id == localMessage.id }) {
                            self?.chatMessages[index].fileUrl = fileUrl
                        }

                        let aiMessage = ChatMessage(
                            id: UUID().uuidString,
                            isUser: false,
                            text: response.response,
                            timestamp: Date(),
                            themeTags: response.themeTags
                        )

                        self?.chatMessages.append(aiMessage)
                        self?.saveMessagesToStorage()
                        completion(.success(response))
                    }
                )
                .store(in: &cancellables)

        } catch {
            isLoading = false
            self.error = "Failed to encode request: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }

    func fetchWeeklySummary(
        userId: String,
        completion: @escaping (Result<WeeklySummary, Error>) -> Void
    ) {
        isLoading = true
        error = nil

        let summaryUrl = "https://ww5yu32db2.execute-api.us-west-2.amazonaws.com/prod/weekly-summary/\(userId)"
        guard let url = URL(string: summaryUrl) else {
            isLoading = false
            error = "Invalid URL"
            completion(.failure(ChatError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ChatError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw ChatError.serverError(message: "Server error: \(httpResponse.statusCode)")
                }
                return data
            }
            .decode(type: WeeklySummary.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionStatus in
                    self?.isLoading = false
                    switch completionStatus {
                    case .finished: break
                    case .failure(let error):
                        self?.error = error.localizedDescription
                        completion(.failure(error))
                    }
                },
                receiveValue: { summary in
                    completion(.success(summary))
                }
            )
            .store(in: &cancellables)
    }

    func clearChatHistory() {
        chatMessages = []
        saveMessagesToStorage()
    }

    public func saveMessagesToStorage() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(chatMessages)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save messages: \(error.localizedDescription)")
        }
    }

    private func loadMessagesFromStorage() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                chatMessages = try decoder.decode([ChatMessage].self, from: data)
            } catch {
                print("Failed to load messages: \(error.localizedDescription)")
            }
        }
    }
    
    func updateRelationshipContext(_ context: RelationshipContext) {
            self.relationshipContext = context
            saveRelationshipContext()
        }
        
        private func saveRelationshipContext() {
            guard let context = relationshipContext else { return }
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(context)
                UserDefaults.standard.set(data, forKey: relationshipContextKey)
            } catch {
                print("Failed to save relationship context: \(error.localizedDescription)")
            }
        }
        
        private func loadRelationshipContext() {
            if let data = UserDefaults.standard.data(forKey: relationshipContextKey) {
                do {
                    let decoder = JSONDecoder()
                    relationshipContext = try decoder.decode(RelationshipContext.self, from: data)
                } catch {
                    print("Failed to load relationship context: \(error.localizedDescription)")
                }
            }
        }
    
    private func loadSavedConversations() {
        if let data = UserDefaults.standard.data(forKey: savedChatsKey) {
            do {
                let decoder = JSONDecoder()
                previousChats = try decoder.decode([ChatPreview].self, from: data)
            } catch {
                print("Failed to load saved conversations: \(error.localizedDescription)")
            }
        }
    }
    
    func saveConversation(_ conversation: ChatPreview) {
        previousChats.append(conversation)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(previousChats)
            UserDefaults.standard.set(data, forKey: savedChatsKey)
        } catch {
            print("Failed to save conversation: \(error.localizedDescription)")
        }
    }
    
    func deleteConversation(at index: Int) {
        guard previousChats.indices.contains(index) else { return }
        previousChats.remove(at: index)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(previousChats)
            UserDefaults.standard.set(data, forKey: savedChatsKey)
        } catch {
            print("Failed to delete conversation: \(error.localizedDescription)")
        }
    }
    
    func loadChat(_ chat: ChatPreview) {
        chatMessages = chat.messages
        saveMessagesToStorage()
    }
    
    func deleteChat(_ chat: ChatPreview) {
        if let index = previousChats.firstIndex(where: { $0.id == chat.id }) {
            deleteConversation(at: index)
        }
    }
    
    func clearAllConversations() {
        previousChats.removeAll()
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(previousChats)
            UserDefaults.standard.set(data, forKey: savedChatsKey)
        } catch {
            print("Failed to clear conversations: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Account Deletion
    struct AccountDeletionRequest: Codable {
        let feedback: String?
    }

    struct AccountDeletionResponse: Codable {
        let message: String
        let gracePeriodEndDate: String
    }

    func requestAccountDeletion(userId: String, feedback: String?, completion: @escaping (Result<AccountDeletionResponse, Error>) -> Void) {
        guard !userId.isEmpty else {
            completion(.failure(ChatError.invalidUserId))
            return
        }
        
        let deletionUrl = apiUrl.replacingOccurrences(of: "/chat", with: "/users/\(userId)")
        
        guard let url = URL(string: deletionUrl) else {
            completion(.failure(ChatError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Add authentication header if needed
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add feedback if provided
        if let feedback = feedback, !feedback.isEmpty {
            let deletionRequest = AccountDeletionRequest(feedback: feedback)
            do {
                let jsonData = try JSONEncoder().encode(deletionRequest)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(ChatError.invalidResponse))
                    return
                }
                
                // 202 Accepted is expected for deletion requests that will be processed
                guard httpResponse.statusCode == 202 else {
                    let errorMessage = data.flatMap {
                        String(data: $0, encoding: .utf8)
                    } ?? "Server error: \(httpResponse.statusCode)"
                    completion(.failure(NSError(domain: "ChatService", code: httpResponse.statusCode,
                                               userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ChatError.noData))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AccountDeletionResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Request and Response Models

/// Request model for chat API
struct ChatRequest: Codable {
    let userId: String
    let message: String
    let sharedWithPartner: Bool
    let fileData: String?
    let fileName: String?
    let relationshipContext: RelationshipContext?
    
    init(userId: String, message: String, sharedWithPartner: Bool, fileData: String? = nil,
         fileName: String? = nil, relationshipContext: RelationshipContext? = nil) {
        self.userId = userId
        self.message = message
        self.sharedWithPartner = sharedWithPartner
        self.fileData = fileData
        self.fileName = fileName
        self.relationshipContext = relationshipContext
    }
}

struct RelationshipContext: Codable {
    let partnerName: String?
    let relationshipStatus: String?
    let relationshipDuration: Int? // in days
    let importantDates: [ImportantDate]?
    let partnerPreferences: [String: String]?
    let userPersonality: [String]?
}

struct ImportantDate: Codable {
    let name: String
    let date: Date
    let description: String?
}

/// Response model from AI
struct AIResponse: Codable {
    let response: String
    let timestamp: Int
    let themeTags: [String]?
    let fileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case response
        case timestamp
        case themeTags
        case fileUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(String.self, forKey: .response)
        timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp) ?? Int(Date().timeIntervalSince1970 * 1000)
        themeTags = try container.decodeIfPresent([String].self, forKey: .themeTags)
        fileUrl = try container.decodeIfPresent(String.self, forKey: .fileUrl)
    }
}

/// Response model for weekly summary
struct WeeklySummary: Codable {
    let summary: String
    let insights: [String]
}

/// Chat message model
struct ChatMessage: Identifiable, Codable {
    let id: String
    let isUser: Bool
    let text: String
    let timestamp: Date
    var themeTags: [String]?
    var fileUrl: String?
    var isUploading: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case isUser
        case text
        case timestamp
        case themeTags
        case fileUrl
        case isUploading
    }
}

struct ChatPreview: Identifiable, Codable {
    let id: String
    let title: String
    let preview: String
    let date: Date
    let messages: [ChatMessage]
    
    init(id: String = UUID().uuidString, title: String, preview: String, date: Date = Date(), messages: [ChatMessage]) {
        self.id = id
        self.title = title
        self.preview = preview
        self.date = date
        self.messages = messages
    }
}

// MARK: - Errors

enum ChatError: Error, LocalizedError {
    case emptyMessage
    case invalidURL
    case invalidResponse
    case serverError(message: String)
    case invalidUserId
    case noData
    
    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Message cannot be empty"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let message):
            return message
        case .invalidUserId:
            return "Invalid user ID"
        case .noData:
            return "No data received"
        }
    }
}
