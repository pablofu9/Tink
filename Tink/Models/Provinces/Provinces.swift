//
//  Provinces.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation

import Foundation

struct Town: Codable, Hashable {
    var parentCode: String
    var code: String
    var label: String
    
    enum CodingKeys: String, CodingKey {
        case parentCode = "parent_code"
        case code
        case label
    }
}

struct Province: Codable, Hashable {
    var parentCode: String
    var code: String
    var label: String
    var towns: [Town]
    
    enum CodingKeys: String, CodingKey {
        case parentCode = "parent_code"
        case code
        case label
        case towns
    }
}

struct AutonomousCommunity: Codable, Hashable {
    var parentCode: String
    var label: String
    var code: String
    var provinces: [Province]
    
    enum CodingKeys: String, CodingKey {
        case parentCode = "parent_code"
        case label
        case code
        case provinces
    }
}

typealias FoodModelContainer = [AutonomousCommunity]
