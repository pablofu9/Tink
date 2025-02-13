//
//  Skill.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import Foundation

struct Skill: Codable {
    var id: String 
    var name: String
    var description: String
    var price: String
    var category: FSCategory
    var user: User
    var is_online: Bool?
}
