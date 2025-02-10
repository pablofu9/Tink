//
//  UIApplication+Utils.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import Foundation
import SwiftUI

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
}
