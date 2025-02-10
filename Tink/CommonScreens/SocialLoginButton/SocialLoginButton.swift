//
//  SocialLoginButton.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import SwiftUI

// Social login
enum SocialButton: CaseIterable {
    case google
    case apple
    
    var image: ImageResource {
        switch self {
        case .google:
            return .googleIcon
        case .apple:
            return .appleIcon

        }
    }
    
    var text: String {
        switch self {
        case .google:
            return "GOOGLE_LOGIN".localized
        case .apple:
            return "APPLE_LOGIN".localized
        }
    }
}


struct SocialLoginButton: View {
    
    // MARK: - PROPERTIES
    // Login with google action
    var googleAction: () -> Void
    // Login with apple action
    var appleAction: () -> Void
    // geometry proxy
    let proxy: GeometryProxy

    var body: some View {
        socialLoginStack(proxy)
    }
}

// MARK: - SUBVIEWS
extension SocialLoginButton {
    
    @ViewBuilder
    private func socialLoginButton(button: SocialButton, _ proxy: GeometryProxy, count: Int, spacing: CGFloat) -> some View {
        Button {
            if button == .google {
                googleAction()
            } else {
                appleAction()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .frame(width: (proxy.size.width - 48 - CGFloat(count - 1) * spacing) / CGFloat(count),height: 60)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                HStack {
                    Image(button.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text(button.text)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                        .font(.custom(CustomFonts.regular, size: 17))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func socialLoginStack(_ proxy: GeometryProxy) -> some View {
        let spacing: CGFloat = 10 // Espaciado entre botones
          let buttonCount = SocialButton.allCases.count
        HStack(spacing: spacing) {
               ForEach(SocialButton.allCases, id: \.self) { social in
                   socialLoginButton(
                        button: social,
                       proxy,
                       count: buttonCount,
                       spacing: spacing
                   )
               }
           }
    }
    
}
