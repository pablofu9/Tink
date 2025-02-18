//
//  ChatManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 18/2/25.
//

import Foundation
import FirebaseFirestore

@MainActor
@Observable
class ChatManager: ObservableObject {
    
    var messages: [Message] = []
    private var db = Firestore.firestore()
    
    /// Send message function
    func sendMessage(chatId: String, senderId: String, text: String) {
        let db = Firestore.firestore()
        
        let message = Message(senderId: senderId, text: text, timestamp: Date())
        
        do {
            let _ = try db.collection("chats").document(chatId).collection("messages").addDocument(from: message)
            
            db.collection("chats").document(chatId).updateData([
                "lastMessage": text,
                "timestamp": Date()
            ])
            
        } catch {
            print("Error al enviar mensaje: \(error)")
        }
    }
    
    /// Listen for messages
    func listenForMessages(chatID: String) {
        db.collection("chats").document(chatID).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error getting messages", error)
                    return
                }
                self.messages = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                } ?? []
            }
    }
    
    /// Create or get chat
    func createOrGetChat(user1Id: String, user2Id: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        let users = [user1Id, user2Id].sorted()
        
        db.collection("chats")
            .whereField("users", isEqualTo: users)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error buscando chat: \(error)")
                    return
                }
                
                if let chat = snapshot?.documents.first {
                    completion(chat.documentID)
                } else {
                    let newChat = Chat(users: users, lastMessage: "", timestamp: Date())
                    do {
                        let ref = try db.collection("chats").addDocument(from: newChat)
                        completion(ref.documentID)
                    } catch {
                        print("Error creando chat: \(error)")
                    }
                }
            }
    }
}
