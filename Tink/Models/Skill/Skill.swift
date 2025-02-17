//
//  Skill.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import Foundation

struct Skill: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var description: String
    var price: String
    var category: FSCategory
    var user: User
    var is_online: Bool?
    
    static func == (lhs: Skill, rhs: Skill) -> Bool {
           return lhs.id == rhs.id 
       }
}

extension Skill {
    static let sample = Skill(
        id: "1",
        name: "Clases online",
        description: "Clases online de ingles",
        price: "5 e/h",
        category: FSCategory.sampleCategory,
        user: User.sampleUser
    )
    static let sample1 = Skill(
        id: "2",
        name: "Esta va a ser el ejemplop de la descripcion",
        description: "Clases online de ingles",
        price: "5 e/h",
        category: FSCategory.sampleCategory,
        user: User.sampleUser
    )
    static let sample2 = Skill(
        id: "3",
        name: "Clases online",
        description: "Clases online de ingles",
        price: "5 e/h",
        category: FSCategory.sampleCategory,
        user: User.sampleUser
    )
    
    static let sampleArray: [Skill] = [
        sample,
        sample1,
        sample2
    ]
}
