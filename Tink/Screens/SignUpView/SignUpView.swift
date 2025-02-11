//
//  SignUpView.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import SwiftUI

struct SignUpView: View {
    
    enum LoginFocus {
        case email
        case password
        case repeatPassword
    }
    
    // MARK: - PROPERTIES
    // Email text
    @State private var email: String = ""
    // Password
    @State private var password: String = ""
    // Repeat password
    @State private var repeatPassword: String = ""
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
extension SignUpView {
    
    // Content view
    @ViewBuilder
    private var content: some View {
        GeometryReader { proxy in
            header
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading ,spacing: 10) {
                    formView
                    signUpbutton
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
                    alreadyAccView
                        .padding(.top, 20)
                }
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
            }
            .padding(.top, Measures.kTopShapeHeight)
            .zIndex(2)
            .scrollBounceBehavior(.basedOnSize)
        }
        .ignoresSafeArea()
        .background(ColorManager.defaultWhite)
        .onTapGesture {
            focus = nil
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Header view
    @ViewBuilder
    private var header: some View {
        ZStack {
            topShape
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    backIcon
                    Text("SIGN_UP_HEADER".localized)
                        .font(.custom(CustomFonts.bold, size: 30))
                        .foregroundStyle(ColorManager.defaultWhite)
                }
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }.ignoresSafeArea()
    }
    
    /// Form view
    @ViewBuilder
    private var formView: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            emailField
            passwordField
            repeatPasswordView
//                .submitLabel(.done)
//                .onSubmit {
//                    withAnimation {
//                        focus = nil
//                    }
//                }
//                .textFieldStyle(LoginTextField(focused: focus == .passwordFocus || focus == .passwordVisibleFocus , isPassword: !password.isEmpty ? true : false) {
//                    if !password.isEmpty {
//                        isPasswordVisible.toggle()
//                        switch focus {
//                        case .passwordFocus:
//                            focus = .passwordVisibleFocus
//                        case .passwordVisibleFocus:
//                            focus = .passwordFocus
//                        default:
//                            return
//                        }
//                    }
//                })
                

            
        }
    }
    
    /// Email field
    @ViewBuilder
    private var emailField: some View {
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
                    focus = .password
                }
            }
            if let signUpError = authenticatorManager.authErrorSignUp {
                if signUpError == .emptyField && email.isEmpty {
                    customError(signUpError.errorDescription)
                }
            }
        }
    }
    
    /// Password field
    @ViewBuilder
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 5) {
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
            .textFieldStyle(LoginTextField(focused: focus == .password))
            .focused($focus, equals: .password)
            .submitLabel(.continue)
            .onSubmit {
                withAnimation {
                    focus = .repeatPassword
                }
            }
            if let signUpError = authenticatorManager.authErrorSignUp {
                if signUpError == .emptyField && password.isEmpty {
                    customError(signUpError.errorDescription)
                }
            }
        }
    }
    
    /// repeat password field
    @ViewBuilder
    private var repeatPasswordView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("SIGN_UP_REPEAT_PASSWORD".localized)
                .foregroundStyle(ColorManager.primaryGrayColor)
                .font(.custom(CustomFonts.regular, size: 17))
            SecureField(
                "",
                text: $repeatPassword,
                prompt: Text(
                    "SIGN_UP_REPEAT_PASSWORD".localized
                )
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.5))
            )
            .textFieldStyle(LoginTextField(focused: focus == .repeatPassword))
            .focused($focus, equals: .repeatPassword)
            .submitLabel(.done)
            .onSubmit {
                withAnimation {
                    focus = nil
                }
            }
            if let signUpError = authenticatorManager.authErrorSignUp {
                if repeatPassword.isEmpty {
                    if signUpError == .emptyField {
                        customError(signUpError.errorDescription)
                    }
                } else {
                    customError(signUpError.errorDescription)
                }
            }
        }
    }
    
    /// Already acc view
    @ViewBuilder
    private var alreadyAccView: some View {
        Button {
            coordinator.pop()
        } label: {
            HStack(spacing: 3) {
                Text("SIGN_UP_ALREADY_ACC".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.regular, size: 17))
                Text("LOGIN_LOG".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.bold, size: 17))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    /// Sign up button
    @ViewBuilder
    private var signUpbutton: some View {
        VStack(alignment: .trailing) {
            DefaultButton(horizontalPadding: 50, text: "SIGN_UP_BUTTON".localized, action: {
                Task {
                    await authenticatorManager.singUp(email: email, password: password, passRepeat: repeatPassword)
                }
            })
        }
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
    
    /// Back icon
    @ViewBuilder
    private var backIcon: some View {
        BackButton(action: {
            coordinator.pop()
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
    }
}

#Preview {
    @Previewable @State  var coordinator = Coordinator<AuthCoordinatorPages>()

    SignUpView()
        .environment(coordinator)
        .environment(AuthenticatorManager())
}
