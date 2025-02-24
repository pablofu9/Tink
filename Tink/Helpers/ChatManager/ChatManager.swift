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
    var chats: [Chat] = []
    private var db = Firestore.firestore()
    var loading: Bool = false
    private var chatListener: ListenerRegistration?
    
    func getChats() async throws {
        loading = true
        defer { loading = false }
        
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        
        // Usa el ID del usuario en lugar del objeto completo
        let userId = user.id
        
        do {
            let querySnapshot = try await db.collection("chats")
                .whereField("users", arrayContains: userId) // Usa el ID del usuario
                .getDocuments()
            
            guard !querySnapshot.documents.isEmpty else {
                print("No chats found")
                return
            }
            
            self.chats = querySnapshot.documents.compactMap { document in
                do {
                    let chat = try document.data(as: Chat.self)
                    return chat
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
    
    @MainActor
    func observeMessages(for chatId: String) {
        db.collection("chats")
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
                        self.messages = chat.messages // Actualiza solo los mensajes de este chat
                    }
                } catch {
                    print("Error decoding chat messages: \(error.localizedDescription)")
                }
            }
    }
    
    func stopObservingMessages() {
        chatListener?.remove()
        chatListener = nil
    }
    
    func observeChats() {
        guard let user = UserDefaults.standard.userSaved else { return }
        
        let userId = user.id
        
        db.collection("chats")
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

    func createChat(with recipientUser: User) async throws {
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        let userIds = [user.id, recipientUser.id]
        let db = Firestore.firestore()
        
        // 1. Verify if chat already exist
        let query = db.collection("chats")
            .whereField("users", arrayContains: user.id)
            .whereField("users", arrayContains: recipientUser.id)
        
        do {
            let querySnapshot = try await query.getDocuments()
            
            // 2. If exist we return
            if !querySnapshot.documents.isEmpty {
                print("Chat already exists")
                return
            }
            
            // 3. If doesnt exist create chat
            var chat = Chat(id: "", messages: [], users: userIds)
            let chatRef = db.collection("chats").document()
            
            chat.id = chatRef.documentID
            try chatRef.setData(from: chat)
            print("✅ New chat created")
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error creating chat: \(error.localizedDescription)"])
        }
    }
    
    func sendMessage(text: String, chatId: String, senderId: String) async throws {
        let db = Firestore.firestore()
        
        // 1. Crear el objeto Message
        let message = Message(
            id: UUID().uuidString, // Generar un ID único para el mensaje
            text: text,
            received: false, // El mensaje no ha sido recibido aún
            timestamp: Date(), // Fecha y hora actual
            users: senderId // 🔹 Guardamos solo el ID del usuario
        )
        
        // 2. Referencia al chat específico
        let chatRef = db.collection("chats").document(chatId)
        
        do {
            // 3. Obtener el chat actual
            let document = try await chatRef.getDocument()
            
            // 4. Verificar si el chat existe
            guard document.exists else {
                throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Chat not found"])
            }
            
            // 5. Agregar el mensaje al array de mensajes en Firestore
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
}
