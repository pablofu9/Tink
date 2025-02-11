//
//  AuthenticationManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import CryptoKit

@Observable
class AuthenticatorManager: NSObject, ASAuthorizationControllerDelegate {
    
    var authState: AuthState = .undefined
    var authError: AuthError?
    var authErrorSignUp: AuthErrorSignUp?
    var authErrorResetPass: AuthErrorResetPassword?
    var finishCheckAuth: Bool = false
    private var currentNonce: String?
    
    /// We watch for the auth status
    @MainActor
    func startListeningToAuthState() async {
        Task {
            _ = Auth.auth().addStateDidChangeListener { _, user in
                withAnimation(.smooth) {
                    self.authState = user != nil ? .authenticated : .notAuthenticated
                    self.finishCheckAuth = true
                }
            }
        }
    }
  
    /// Sign in with email func
    @MainActor
    func emailPasswordSignIn(email: String, password: String) async {
        do {
            // 1. Login succes
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
            authError = nil
        } catch {
            // 2. Login error
                // 2.1. Empty fields
            if email.isEmpty {
                authError = .emptyEmail
            } else if password.isEmpty {
                authError = .emptyPass
            } else {
                // 2.2. Custom error
                authError = AuthErrorMapper.map(error)
            }
        }
    }
    
    /// Sign up with email func
    @MainActor
    func singUp(email: String, password: String, passRepeat: String) async  {
        do {
            // 1. Sign up
            if password != passRepeat {
                self.authErrorSignUp = .passNotMatch
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        // 2. Any field is empty
                        if email.isEmpty || password.isEmpty || passRepeat.isEmpty {
                            self.authErrorSignUp = .emptyField
                        } else {
                            // 3. No empty fields but error
                            self.authErrorSignUp = AuthErrorMapper.mapSignUpError(error)
                        }
                    } else {
                        // 4. Sign up success
                        self.authErrorSignUp = nil
                    }
                }
            }
        }
    }
    
    /// Sign out function
    func signOut()  throws {
        try Auth.auth().signOut()
        authState = .notAuthenticated
        resetProfile()
    }
    
    @MainActor
    func resetPassword(email: String, goBackAction: @escaping () -> Void) {
        // 1. Empty email error
        guard !email.isEmpty else {
            authErrorResetPass = .emptyEmail
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                // 2. Custom Error
                self.authErrorResetPass = .custom(message: error.localizedDescription)
            } else {
                // 3. No error we go back in view
                self.authErrorResetPass = nil
                goBackAction()
            }
        }
    }
    
    /// Reset auth errors
    func resetAuthErrors() {
        authErrorSignUp = nil
        authError = nil
        authErrorResetPass = nil
    }
    
    func updateUserDefaultsProfile(name: String, image: String) {
        UserDefaults.standard.profileName = name
        UserDefaults.standard.profileImage = image
    }
    
    func resetProfile() {
        UserDefaults.standard.profileName = ""
        UserDefaults.standard.profileImage = ""
    }
}

// MARK: - GOOGLE AUTH
extension AuthenticatorManager {
    
    @MainActor
    func googleSignIn() async throws {
        guard let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController else { return }
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else { return }
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        try await Auth.auth().signIn(with: credential)
        let userProfile = result.user.profile
        let userName = userProfile?.name
        let profileImageURL = userProfile?.imageURL(withDimension: 200)
        updateUserDefaultsProfile(name: userName ?? "", image: (profileImageURL?.absoluteString ?? ""))
    }
}

// MARK: - APPLE SIGN IN
extension AuthenticatorManager {
   
    /// Generate nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    /// Encryptation for apple sign in
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    /// Request apple authorization
    func requestAppleAuthorization(_ request: ASAuthorizationAppleIDRequest) {
        // 1. Generate nonce and store it
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce) // Usa el nonce generado
    }
    
    ///  Apple Sign-In
    @MainActor
    func appleSignIn() {
        // Genera un nonce y guárdalo en la variable
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce) // Usa el nonce generado
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    /// Did complete authoriaztion
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let idTokenData = appleIDCredential.identityToken else { return }
            
            let idTokenString = String(data: idTokenData, encoding: .utf8) ?? ""
            guard let currentNonce = currentNonce else { return }
            
            let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: currentNonce)
            
            Task {
                do {
                    try await Auth.auth().signIn(with: credential)
                    authState = .authenticated
                } catch {
                    print("Error with apple sign in: \(error.localizedDescription)")
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error with apple auth: \(error.localizedDescription)")
    }
}
