//
//  ResetPasswordView.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 24/1/25.
//

import SwiftUI

struct ResetPasswordView: View {
    
    // MARK: - PROPERTIES
    // AuthenticationManager
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    // Email field
    @State private var email: String = ""
    // Email focus
    @FocusState private var focus
    // Coordinator manager
    @Environment(Coordinator<AuthCoordinatorPages>.self) private var coordinator
    // Correo sent alert
    @State private var sentEmailDone: Bool = false
    
    // MARK: - BODY
    var body: some View {
        content
            .navigationBarBackButtonHidden()
            .navigationBarHidden(true)
            .onDisappear {
                authenticatorManager.resetAuthErrors()
            }
            .overlay {
                if sentEmailDone {
                    CustomAlert(title: "SIGN_UP_EMAIL_SENT".localized, bodyText: "SIGN_UP_EMAIL_SENT_BODY".localized, acceptAction: {
                        withAnimation {
                            sentEmailDone = false
                            coordinator.pop()
                        }
                    }, cancelAction: nil)
                }
            }
    }
}

// MARK: - RESET PASSWORD
extension ResetPasswordView {

    /// Content view
    @ViewBuilder
    private var content: some View {
        GeometryReader { reader in
            ScrollView {
                LazyVStack(spacing: 60) {
                    header
                    emailField
                        .padding(.top, 60)
                    resetPasswordButton
                }
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
            }
            .zIndex(2)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            topShape
                .ignoresSafeArea()
        }
        .onTapGesture {
            focus = false
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.defaultWhite)
    }
    
    /// Back icon
    @ViewBuilder
    private var backIcon: some View {
        BackButton(action: {
            coordinator.pop()
        })
    }
    
    /// Header view
    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 20) {
                backIcon
                Text("FORGOT_PASSWORD_HEADER".localized)
                    .font(.custom(CustomFonts.bold, size: 30))
                    .foregroundStyle(ColorManager.defaultWhite)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Email textfield
    @ViewBuilder
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("SIGN_UP_EMAIL_SENT_BODY".localized)
                .foregroundStyle(ColorManager.defaultBlack.opacity(0.7))
                .font(.custom(CustomFonts.regular, size: 17))
                .padding(.bottom, 20)
            Text("LOGIN_EMAIL".localized)
                .foregroundStyle(ColorManager.primaryGrayColor)
                .font(.custom(CustomFonts.regular, size: 17))
            TextField(
                "",
                text: $email,
                prompt: Text(
                    "LOGIN_EMAIL".localized
                )
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.5))
            )
            .textFieldStyle(LoginTextField(focused: focus))
            .focused($focus)
            .submitLabel(.continue)
            .onSubmit {
                withAnimation {
                    focus = false
                }
            }
            if let resetPasswordError = authenticatorManager.authErrorResetPass {
                customError(resetPasswordError.errorDescription)
            }
        }
    }
    
    /// Reset password button
    @ViewBuilder
    private var resetPasswordButton: some View {
        DefaultButton(horizontalPadding: 10, text: "FORGOT_PASSWORD_BUTTON".localized, action: {
            Task {
                 authenticatorManager.resetPassword(email: email, goBackAction: {
                     withAnimation {
                         focus = false
                         sentEmailDone = true
                     }
                })
            }
        })
    }
    
    @ViewBuilder
    private func customError(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(ColorManager.cancelColor)
            .font(.custom(CustomFonts.regular, size: 16))
            .transition(.opacity)
    }
    
    /// Top shape view
    @ViewBuilder
    private var topShape: some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: Measures.kTopShapeHeight, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
            .zIndex(1)
    }
}

#Preview {
    @Previewable @State  var coordinator = Coordinator<AuthCoordinatorPages>()

    ResetPasswordView()
        .environment(coordinator)
        .environment(AuthenticatorManager())

}
