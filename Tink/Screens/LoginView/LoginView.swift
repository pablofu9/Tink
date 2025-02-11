//
//  LoginView.swift
//  Map It
//
//  Created by Pablo Fuertes ruiz on 22/1/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    
    // Focus controller enum
    enum LoginFocus {
        case email
        case passwordFocus
    }
    
    enum LoginErrorPosition {
        case email
        case pass
    }
    
    // MARK: - PROPERTIES
    // Email text
    @State private var email: String = ""
    // Password
    @State private var password: String = ""
    // Focus state
    @FocusState private var focus: LoginFocus?
    // AuthenticationManager
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    // Coordinator
    @Environment(Coordinator<AuthCoordinatorPages>.self) private var coordinator

    // MARK: - BODY
    var body: some View {
        content
            .navigationBarBackButtonHidden()
            .navigationBarHidden(true)
            .onDisappear {
                authenticatorManager.resetAuthErrors()
            }
    }
}

// MARK: - SUBVIEWS
extension LoginView {
    
    /// Content view
    @ViewBuilder
    private var content: some View {
        GeometryReader { proxy in
            header
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading ,spacing: 10) {
                    formView
                    loginButton
                        .padding(.top, 37)
                    dividerView
                        .padding(.vertical, 40)
                    SocialLoginButton(googleAction: {
                        Task {
                            try await authenticatorManager.googleSignIn()
                        }
                    }, appleAction: {
                        Task {
                            authenticatorManager.appleSignIn()
                        }
                    }, proxy: proxy)
                    alreadyAcc
                        .padding(.top, 20)
                }
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
            }
            .padding(.top, Measures.kTopShapeHeight)
            .scrollBounceBehavior(.basedOnSize)
        }
        .ignoresSafeArea()
        .background(ColorManager.defaultWhite)
        .onTapGesture {
            focus = nil
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    /// Top shape view
    @ViewBuilder
    private var topShape: some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: Measures.kTopShapeHeight, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
    }
    
    /// Header view
    @ViewBuilder
    private var header: some View {
        ZStack {
            topShape
            VStack(alignment: .leading,spacing: 0) {
                Text("LOGIN_WELCOME_BACK".localized)
                    .font(.custom(CustomFonts.bold, size: 30))
                    .foregroundStyle(ColorManager.defaultWhite)
                Text("LOGIN_LOG".localized)
                    .font(.custom(CustomFonts.regular, size: 16))
                    .foregroundStyle(ColorManager.defaultWhite)
            }
        }
        .ignoresSafeArea()
    }
    
    /// Form view
    @ViewBuilder
    private var formView: some View {
        LazyVStack(alignment: .leading, spacing: 50) {
            VStack(alignment: .leading, spacing: 5) {
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
                    .textFieldStyle(LoginTextField(focused: focus == .email))
                    .focused($focus, equals: .email)
                    .submitLabel(.continue)
                    .onSubmit {
                        withAnimation {
                            focus = .passwordFocus
                        }
                    }
                if let authError = authenticatorManager.authError {
                    if authError == .emptyEmail || authError == .invalidEmail {
                        customError(authError.errorDescription)
                    }
                }
            }
            VStack (alignment: .leading, spacing: 5) {
                Text("LOGIN_PASSWORD".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.regular, size: 17))
                SecureField(
                    "",
                    text: $password,
                    prompt: Text(
                        "LOGIN_PASSWORD".localized
                    )
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.5))
                )
                .textFieldStyle(LoginTextField(focused: focus == .passwordFocus))
                .focused($focus, equals: .passwordFocus)
                .submitLabel(.done)
                .onSubmit {
                    withAnimation {
                        focus = nil
                    }
                }
                
                if let authError = authenticatorManager.authError {
                    if authError != .emptyEmail && authError != .invalidEmail {
                        customError(authError.errorDescription)
                    }
                }
                forgotPassword
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    /// Forgort password bien
    @ViewBuilder
    private var forgotPassword: some View {
        Button {
            coordinator.push(.resetPassword)
        } label: {
            Text("LOGIN_FORGOT_PASSWORD".localized)
                .foregroundStyle(ColorManager.primaryGrayColor)
                .font(.custom(CustomFonts.regular, size: 14))
                .underline()
        }
    }
    
    /// Login button
    @ViewBuilder
    private var loginButton: some View {
        DefaultButton(horizontalPadding: 50, text: "LOGIN_BUTTON_TEXT".localized, action: {
            Task {
                await authenticatorManager.emailPasswordSignIn(email: email, password: password)
            }
        })
    }
    
    /// Divider view
    @ViewBuilder
    private var dividerView: some View {
        HStack(spacing: 20) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(ColorManager.primaryGrayColor)
            Text("LOGIN_TEXT_OR_CONTINUE".localized)
                .font(.custom(CustomFonts.regular, size: 16))
                .foregroundStyle(ColorManager.primaryGrayColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(ColorManager.primaryGrayColor)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Already have acc
    @ViewBuilder
    private var alreadyAcc: some View {
        Button {
            coordinator.push(.signup)
        } label: {
            HStack(spacing: 3) {
                Text("LOGIN_NO_ACC".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.regular, size: 17))
                Text("SIGN_UP_BUTTON".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.bold, size: 17))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    private func customError(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(ColorManager.cancelColor)
            .font(.custom(CustomFonts.regular, size: 16))
            .transition(.opacity)
    }
}

#Preview {
    @Previewable @State  var coordinator = Coordinator<AuthCoordinatorPages>()
    LoginView()
        .environment(coordinator)
        .environment(AuthenticatorManager())
}
