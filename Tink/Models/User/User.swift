//
//  User.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation

// MARK: - USER
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var community: String
    var province: String
    var locality: String
}

extension User {
    static let sampleUser =  User(id: "1", name: "Juan", email: "Juan@gmail.com", community: "Madrid", province: "Madrid", locality: "Madrid")
}
