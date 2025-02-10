//
//  AppSwitcher.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import SwiftUI

struct AppSwitcher: View {
    
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    
    var body: some View {
        ZStack {
            if authenticatorManager.authState == .notAuthenticated {
                CoordinatorStack(AuthCoordinatorPages.login)
                    .transition(.move(edge: .bottom))
            } else {
                MainView()
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

#Preview {
    AppSwitcher()
        .environment(AuthenticatorManager())
}
