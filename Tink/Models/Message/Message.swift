//
//  Message.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import Foundation

struct Message: Identifiable, Codable, Hashable {
    var id: String
    var text: String
    var received: Bool
    var timestamp: Date
    var users: String
}

struct Chat: Identifiable, Codable {
    var id: String
    var messages: [Message]
    var users: [String]
}
