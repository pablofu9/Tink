//
//  FSCategory.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import Foundation

struct FSCategory: Identifiable,Codable, Equatable, Hashable {
    var id: String
    var name: String
    var is_manual: Bool?
    var image_url: String?
}

extension FSCategory: CustomStringConvertible {
    var description: String { name }
}

extension FSCategory {
    static let sampleCategory = FSCategory(id: "1", name: "Clases online", image_url: "https://images.pexels.com/photos/2244746/pexels-photo-2244746.jpeg?auto=compress&cs=tinysrgb&w=250&h=250&dpr=2")
}
