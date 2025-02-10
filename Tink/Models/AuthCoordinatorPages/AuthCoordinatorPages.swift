//
//  AuthCoordinatorPages.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import Foundation
import SwiftUI

enum AuthCoordinatorPages: Coordinatable {
    nonisolated var id: UUID { .init() }
    case login
    case signup
    case resetPassword

    
    var body: some View {
        switch self {
        case .login: LoginView()
        case .signup: SignUpView()
        case .resetPassword: ResetPasswordView()
        }
    }
}
