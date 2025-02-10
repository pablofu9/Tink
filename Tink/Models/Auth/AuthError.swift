//
//  AuthError.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import Foundation
import FirebaseAuth

// Logtin error management
enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case networkError
    case unknownError
    case emptyEmail
    case emptyPass
    case custom(message: String)
    
    
    var errorDescription: String {
        switch self {
        case .invalidEmail:
            return "LOGIN_ERROR_INVALID".localized
        case .wrongPassword:
            return "LOGIN_ERROR_INVALID_PASS".localized
        case .userNotFound:
            return "LOGIN_ERROR_INVALID_USER".localized
        case .networkError:
            return "LOGIN_ERROR_NETWORK".localized
        case .unknownError:
            return "LOGIN_ERROR_UNKNOW".localized
        case .emptyEmail:
            return "LOGIN_ERROR_EMAIL".localized
        case .emptyPass:
            return "LOGIN_ERROR_PASS".localized
        case .custom(_):
            return "LOGIN_DEFAULT_ERROR".localized
        }
    }
}

// sign up error management
enum AuthErrorSignUp: LocalizedError, Equatable {
    case invalidEmail
    case emailInUse
    case weakPassword
    case networkError
    case unknownError
    case passNotMatch
    case emptyField
    case custom(message: String)

    var errorDescription: String {
        switch self {
        case .invalidEmail:
            return "LOGIN_ERROR_INVALID".localized
        case .emailInUse:
            return "LOGIN_ERROR_EMAIL_IN_USE".localized
        case .weakPassword:
            return "LOGIN_ERROR_WEAK_PASS".localized
        case .networkError:
            return "LOGIN_ERROR_NETWORK".localized
        case .unknownError:
            return "LOGIN_ERROR_UNKNOW".localized
        case .passNotMatch:
            return "LOGIN_ERROR_PASSWORD_NOT_MATCH".localized
        case .emptyField:
            return "LOGIN_ERROR_EMPTY_FIELD".localized
        case .custom(message: let message):
            return message
        }
    }
}

// Reset password error management
enum AuthErrorResetPassword: LocalizedError, Equatable {
    case emptyEmail
    case custom(message: String)

    var errorDescription: String {
        switch self {
        case .emptyEmail:
            return "LOGIN_ERROR_EMAIL".localized
        case .custom(message: let message):
            return message
        }
    }
}

// Error Mapper
struct AuthErrorMapper {
    static func map(_ error: Error) -> AuthError {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        default:
            return .custom(message: nsError.localizedDescription)
        }
    }
    
    static func mapSignUpError(_ error: Error) -> AuthErrorSignUp {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailInUse
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        default:
            return .custom(message: nsError.localizedDescription)
        }
    }
}

// Authorization state
enum AuthState {
    case undefined
    case authenticated
    case notAuthenticated
}
