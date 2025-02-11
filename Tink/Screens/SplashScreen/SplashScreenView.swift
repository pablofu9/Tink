//
//  SplashScreenView.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 24/1/25.
//

import SwiftUI

struct SplashScreenView: View {
    
    // MARK: - PROPERTIES
    // Authentication manager
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    // Database manager
    @EnvironmentObject var databaseManager: FSDatabaseManager
    
    // MARK: - BODY
    var body: some View {
        if authenticatorManager.finishCheckAuth {
            AppSwitcher()
                .transition(.move(edge: .bottom))

        } else {
            splashView
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        }
    }
}

// MARK: - SUBVIEWS
extension SplashScreenView {
    
    // Splash view
    @ViewBuilder
    private var splashView: some View {
        VStack(spacing: 0) {
            topShape
            Spacer()
            Image(.splashLogo)
                .resizable()
                .frame(width: 200, height: 200)
            Text("TINK")
                .font(.custom(CustomFonts.bold, size: 40))
                .foregroundStyle(ColorManager.primaryBasicColor)
            Spacer()
            topShape
                .rotationEffect(.degrees(180))
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.defaultWhite)
        .task {
            await checkAuthState()
        }
    }
    
    // Check auth state
    private func checkAuthState() async {
        // 1 Second w8
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await authenticatorManager.startListeningToAuthState()        
    }
    
    /// Top shape view
    @ViewBuilder
    private var topShape: some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: Measures.kTopShapeHeight, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
    }
}

#Preview {
    SplashScreenView()
        .environment(AuthenticatorManager())
        .environmentObject(FSDatabaseManager())
}





