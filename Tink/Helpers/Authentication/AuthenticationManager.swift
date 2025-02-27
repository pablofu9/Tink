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
import FirebaseFirestore

@Observable
class AuthenticatorManager: NSObject, ASAuthorizationControllerDelegate {
    
    var authState: AuthState = .undefined
    var authError: AuthError?
    var authErrorSignUp: AuthErrorSignUp?
    var authErrorResetPass: AuthErrorResetPassword?
    var finishCheckAuth: Bool = false
    private var currentNonce: String?
    let initialService = InitialService()
    var loading = false
    /// We watch for the auth status
    @MainActor
    func startListeningToAuthState() async {
        Task {
            _ = Auth.auth().addStateDidChangeListener { _, user in
                withAnimation(.smooth) {
                    self.authState = user != nil ? .authenticated : .notAuthenticated
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
    
    func getFirebaseIDToken(completion: @escaping (String?) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("Error getting Firebase ID token: \(error)")
                completion(nil)
                return
            }
            
            // Aquí tienes el token de Firebase
            completion(token)
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
        resetProfile()
        try Auth.auth().signOut()
        authState = .notAuthenticated
    }
    
    @MainActor
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        // 1. Check if the email is empty
        guard !email.isEmpty else {
            authErrorResetPass = .emptyEmail
            completion(false)
            return
        }
        
        // 2. Validate email format
        guard isValidEmail(email) else {
            authErrorResetPass = .wrongEmail
            completion(false)
            return
        }
        
        // 3. Attempt to send the password reset email
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                // Custom error handling
                self.authErrorResetPass = .custom(message: error.localizedDescription)
                completion(false)
            } else {
                // No errors, mark as success
                self.authErrorResetPass = nil
                completion(true)
            }
        }
    }
    
    /// **Validates email format using a regular expression**
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    /// Reset auth errors
    func resetAuthErrors() {
        authErrorSignUp = nil
        authError = nil
        authErrorResetPass = nil
    }
    
    /// Reset profile
    func resetProfile() {
        UserDefaults.standard.userSaved = nil
    }
    
    /// Delete account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            let publicId = "user_\(user.uid)"
            CloudinaryManager.shared.deleteImage(publicId: publicId)
            try await user.delete()
            print("Account deleted from firebase with success!!")
        } catch {
            print("Error deleting account: \(error.localizedDescription)")
        }
    }
    
    func getProvider() async throws -> ProviderResult? {
        var provider: ProviderResult?
        if let user = Auth.auth().currentUser {
            for data in user.providerData {
                switch data.providerID {
                case "password":
                    provider = .email
                case "google.com":
                    provider = .google
                case "apple.com":
                    provider = .apple
                default:
                    provider = .email
                }
            }
           
        }
        return provider
    }
    
    func reauthenticate(password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    /// Function to check if user already exists
    func handleUserInFirestore() {
        loading = true
        defer { loading = false }
        // 1. Check if user is authenticated
        guard let user = Auth.auth().currentUser else {
            print("No user authenticated")
            return
        }
        guard UserDefaults.standard.userSaved == nil else {
            print("User already saved in UD")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        // 3. Get document in Users
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                // 3.1. User exist in firestore ->
                do {
                    print("User already exist save in firestore")
                    let user = try document.data(as: User.self)
                    UserDefaults.standard.userSaved = user
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                // 3.2. User doesnt exist in firestore ->
                let name =  (user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                ? user.displayName!
                : user.email?.components(separatedBy: "@").first ?? ""
                let savedUser = User(id: user.uid, name: name, email: user.email ?? "")
                do {
                    let encondedUser = try Firestore.Encoder().encode(savedUser)
                    // 4. Saved new user in firestore
                    userRef.setData(encondedUser, merge: true) { error in
                        if let error {
                            print("Error saving new user in firestore", error)
                            Task {
                                try self.signOut()
                            }
                        } else {
                            print("User saved correctly")
                            UserDefaults.standard.userSaved = savedUser
                        }
                    }
                } catch {
                    Task {
                        try self.signOut()
                    }
                    print("Error decoding User")
                }
            }
        }
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

// MARK: - FIRESTORE USER
extension AuthenticatorManager {
    

}

enum ProviderResult {
    case email
    case google
    case apple
}
