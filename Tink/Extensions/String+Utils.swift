//
//  String+Utils.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//
import Foundation

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
