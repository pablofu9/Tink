//
//  SplashScreenView.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 24/1/25.
//

import SwiftUI

struct SplashScreenView: View {
    
    // MARK: - PROPERTIES
    @Environment(AuthenticatorManager.self) private var authenticatorManager

    // MARK: - BODY
    var body: some View {
        if authenticatorManager.finishCheckAuth {
            AppSwitcher()
        } else {
            splashView
        }
    }
}

// MARK: - SUBVIEWS
extension SplashScreenView {
    
    // Splash view
    @ViewBuilder
    private var splashView: some View {
        VStack(spacing: 25) {
            Text("SPLASH")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorManager.defaultWhite)
        .task {
            await checkAuthState()
        }
    }
    
    private func checkAuthState() async {
        // 1 Second w8
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await authenticatorManager.startListeningToAuthState()
    }
}

#Preview {
    SplashScreenView()
        .environment(AuthenticatorManager())
}





