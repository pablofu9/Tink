//
//  APICall.swift
//  snnemployee
//
//  Created by Pablo Fuertes on 11/7/24.
//

import Foundation

/// A protocol defining the requirements for making API calls.
protocol APICall {
    
    /// The path of the API endpoint.
    var path: String { get }
    
    /// The HTTP method for the API call.
    var method: HTTPMethod { get }
    
    /// A boolean indicating whether the API call requires authentication.
    var authenticated: Bool { get }
    
    /// Asynchronously provides the headers for the API call.
    func headers() async throws -> [String: String]?
    
    /// Asynchronously provides the request body data for the API call.
    func body() throws -> Data?
}

/// An enumeration representing HTTP methods.
enum HTTPMethod: String {
    case get  = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// An enumeration representing possible API errors.
enum APIError: Error {
    case invalidURL
    case unauthorized
    case httpCode(HTTPCode)
    case unexpectedResponse
    case decoding(Error)
}

/// An extension to provide localized descriptions for API errors.
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .unauthorized: return "Unauthorized"
        case let .httpCode(code): return "Unexpected HTTP code: \(code)"
        case .unexpectedResponse: return "Unexpected response from the server"
        case let .decoding(error): return "Error decoding: \(error)"
        }
    }
}

/// An extension to provide default implementations for APICall protocol methods.
extension APICall {
    
    /// Constructs a URLRequest for the API call.
    /// - Parameter baseURL: The base URL for the API.
    func urlRequest(baseURL: String) async throws -> URLRequest {
        let fullURL = baseURL + path

        guard let url = URL(string: fullURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = try await headers()
        request.httpBody = try body()
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        return request
    }
}

/// Type alias representing HTTP status code.
typealias HTTPCode = Int

/// Type alias representing a range of HTTP status codes.
typealias HTTPCodes = Range<HTTPCode>

/// An extension to provide common HTTP status code ranges.
extension HTTPCodes {
    static let success = 200 ..< 300
    static let unauthorized = 401
}

/// An extension to provide NSString compatibility for String.
extension String {
    var ns: NSString { return self as NSString }
    
    /// Appends a path component to the current string.
    /// - Parameter path: The path component to append.
    func appendingPathComponent(_ path: String) -> String {
        return self.ns.appendingPathComponent(path)
    }
}
