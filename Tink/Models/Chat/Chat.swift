//
//  Chat.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 18/2/25.
//

import Foundation
import FirebaseFirestore

// MARK: - CHAT
struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var users: [String]
    var lastMessage: String
    var timestamp: Date
}

// MARK: - MESSAGE
struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Date
}
