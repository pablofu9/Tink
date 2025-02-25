//
//  User.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation

// MARK: - USER
struct User: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var email: String
    var profileImageURL: String?
}

extension User {
    static let sampleUser =  User(id: "1", name: "Juan agapito revilla de la santa espina", email: "Juan@gmail.com", profileImageURL: nil)
    static let userDefaultSample = User(id: "2", name: "Pedro", email: "Juan@gmail.com", profileImageURL: "https://res.cloudinary.com/dbzimmpcy/image/upload/v1739975987/user_rRXxJcYuUTgC12krzxz6ZDT7CbO2.jpg")
}
