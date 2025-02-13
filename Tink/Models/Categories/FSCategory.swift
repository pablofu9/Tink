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
