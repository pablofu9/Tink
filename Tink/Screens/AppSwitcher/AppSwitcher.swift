//
//  AppSwitcher.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import SwiftUI

struct AppSwitcher: View {
    
    // MARK: - PROPERTIES
    // Authentication manager
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    // Database manager
    @EnvironmentObject var databaseManager: FSDatabaseManager

    // MARK: - BODY
    var body: some View {
        ZStack {
            if authenticatorManager.authState == .notAuthenticated {
                CoordinatorStack(AuthCoordinatorPages.login)
                    .transition(.move(edge: .bottom))
            } else {
                MainCoordinatorStack(MainCoordinatorPages.root)
                    .transition(.move(edge: .bottom))
            }
        }
        .environmentObject(databaseManager)
    }
}

#Preview {
    AppSwitcher()
        .environment(AuthenticatorManager())
        .environmentObject(FSDatabaseManager())
}
