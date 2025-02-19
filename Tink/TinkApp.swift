//
//  TinkApp.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 7/2/25.
//

import SwiftUI

@main
struct TinkApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authenticatorManager: AuthenticatorManager
    @StateObject private var databaseManager = FSDatabaseManager()
    
    init() {
        _authenticatorManager = State(wrappedValue: AuthenticatorManager())
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(authenticatorManager)
                .environmentObject(databaseManager)
        }
    }
}
