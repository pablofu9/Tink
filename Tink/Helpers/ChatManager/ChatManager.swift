//
//  ChatManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 18/2/25.
//

import Foundation
import FirebaseFirestore

/// Manages chat-related operations such as fetching, observing, creating, and deleting chats.
@MainActor
@Observable
class ChatManager: ObservableObject {
    
    /// List of messages in the currently selected chat.
    var messages: [Message] = []
    
    /// Message listener
    private var messageListener: ListenerRegistration?
    
    /// List of chats in which the user is a participant.
    var chats: [Chat] = []
    
    /// Chart listener
    private var chatListener: ListenerRegistration?
    
    /// Firestore database reference.
    private var db = Firestore.firestore()
    
    /// Indicates whether data is currently being loaded.
    var loading: Bool = false
    
    /// Retrieves the list of chats for the authenticated user.
    /// - Throws: An error if Firestore operations fail.
    func getChats() async throws {
        loading = true
        defer { loading = false }
        
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        
        let userId = user.id
        
        do {
            let querySnapshot = try await db.collection("chats")
                .whereField("users", arrayContains: userId)
                .getDocuments()
            
            guard !querySnapshot.documents.isEmpty else {
                print("No chats found")
                return
            }
            
            self.chats = querySnapshot.documents.compactMap { document in
                do {
                    return try document.data(as: Chat.self)
                } catch {
                    print("Error decoding chat: \(error.localizedDescription)")
                    return nil
                }
            }
        } catch {
            print("Error getting chats: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Observes real-time updates for messages in a specific chat.
    /// - Parameter chatId: The ID of the chat to observe.
    @MainActor
    func observeMessages(for chatId: String) {
        messageListener = db.collection("chats")
            .document(chatId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting chat messages: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("Chat not found")
                    return
                }
                
                do {
                    let chat = try document.data(as: Chat.self)
                    DispatchQueue.main.async {
                        self.messages = chat.messages
                    }
                  
                } catch {
                    print("Error decoding chat messages: \(error.localizedDescription)")
                }
            }
    }
    
    /// Observes real-time updates for the list of chats of the authenticated user.
    func observeChats() {
        guard let user = UserDefaults.standard.userSaved else { return }
        
        let userId = user.id
        
        chatListener = db.collection("chats")
            .whereField("users", arrayContains: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No chats found")
                    return
                }
                
                DispatchQueue.main.async {
                    self.chats = documents.compactMap { document in
                        try? document.data(as: Chat.self)
                    }
                }
            }
    }
    
    /// Stops observing chats to free up resources.
    func stopObservingChats() {
        chatListener?.remove()
        chatListener = nil
        print("🛑 Stopped observing chats")
    }
    
    /// Stops observing messages to free up resources.
    func stopObservingMessages() {
        messageListener?.remove()
        messageListener = nil
        print("🛑 Stopped observing messages")
    }
    
    /// Creates a new chat between the authenticated user and another user.
    /// If a chat already exists, the function returns without creating a new one.
    /// - Parameter recipientUser: The user to start the chat with.
    /// - Throws: An error if Firestore operations fail.
    func createChat(with recipientUser: User) async throws {
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        
        let userIds = [user.id, recipientUser.id]
        let db = Firestore.firestore()
        
        let query = db.collection("chats")
            .whereField("users", arrayContains: user.id)
        
        do {
            let querySnapshot = try await query.getDocuments()
            
            let existingChat = querySnapshot.documents.first { document in
                let chatUsers = document["users"] as? [String] ?? []
                return chatUsers.contains(recipientUser.id)
            }
            
            if existingChat != nil {
                print("Chat already exists")
                return
            }
            
            var chat = Chat(id: "", messages: [], users: userIds)
            let chatRef = db.collection("chats").document()
            
            chat.id = chatRef.documentID
            try chatRef.setData(from: chat)
            print("✅ New chat created")
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error creating chat: \(error.localizedDescription)"])
        }
    }
    
    /// Sends a new message to a specific chat.
    /// - Parameters:
    ///   - text: The text content of the message.
    ///   - chatId: The ID of the chat where the message is sent.
    ///   - senderId: The ID of the sender.
    /// - Throws: An error if the message cannot be sent.
    func sendMessage(text: String, chatId: String, senderId: String) async throws {
        let db = Firestore.firestore()
        
        let message = Message(
            id: UUID().uuidString,
            text: text,
            received: false,
            timestamp: Date(),
            users: senderId
        )
        
        let chatRef = db.collection("chats").document(chatId)
        
        do {
            let document = try await chatRef.getDocument()
            
            guard document.exists else {
                throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Chat not found"])
            }
            
            try await MainActor.run {
                chatRef.updateData([
                    "messages": FieldValue.arrayUnion([try Firestore.Encoder().encode(message)])
                ])
            }
            
            print("✅ Message sent successfully")
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error sending message: \(error.localizedDescription)"])
        }
    }
    
    /// Updates the 'received' status of messages in the current chat when the user has read them.
    /// It marks messages as received for messages that are not sent by the current user.
    /// The changes are reflected both locally and in Firestore.
    ///
    /// - Throws: An error if updating the messages in Firestore or encoding the data fails.
    func changeReadMessage(chat: Chat) async throws {
        // Check if there are any messages in the current chat
        if !messages.isEmpty {
            // Create an updated list of messages, marking as received only those that have 'received' == false
            let updatedMessages = messages.map { message -> Message in
                // If the message is not sent by the current user and it's not already marked as 'received', mark it as received
                if message.users != UserDefaults.standard.userSaved?.id && !message.received {
                    var updatedMessage = message
                    updatedMessage.received = true
                    return updatedMessage
                }
                // If the message is already marked as 'received' or is sent by the current user, keep it unchanged
                return message
            }
            
            let chatRef = db.collection("chats").document(chat.id)
            let updatedData: [String: Any] = [
                "messages": updatedMessages.map { message in
                    return [
                        "id": message.id,
                        "text": message.text,
                        "users": message.users,
                        "received": message.received,
                        "timestamp": message.timestamp
                    ]
                }
            ]
            do {
                try await chatRef.updateData(updatedData)
                print("Updated messaged")
            } catch {
                print("Error updating messaging", error)
            }
        }
    }

        
    /// Deletes a chat from Firestore if the current user is part of it.
    /// - Parameter chat: The `Chat` object to be deleted.
    /// - Throws: An error if the chat deletion fails.
    func deleteChat(_ chat: Chat) async throws {
        guard let user = UserDefaults.standard.userSaved else {
            print("❌ No user saved in UserDefaults")
            return
        }
        
        let db = Firestore.firestore()
        let chatRef = db.collection("chats").document(chat.id)
        
        do {
            let document = try await chatRef.getDocument()
            
            if let data = document.data(), let users = data["users"] as? [String], users.contains(user.id) {
                try await chatRef.delete()
                print("✅ Chat deleted successfully")
            } else {
                print("⚠️ User is not part of this chat or chat does not exist")
            }
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error deleting chat: \(error.localizedDescription)"])
        }
    }
}

