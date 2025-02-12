//
//  WebRepository.swift
//  snnemployee
//
//  Created by Pablo Fuertes on 11/7/24.
//

import Foundation

/// A protocol defining the requirements for a web repository.
protocol WebRepository {
    /// The URLSession used for network requests.
    var session: URLSession { get }
    
    /// The base URL of the web repository.
    var baseURL: String { get }
    
    /// The JSON decoder used for decoding responses.
    var decoder: JSONDecoder { get }
}

extension WebRepository {
    /// Default JSON decoder used when not provided explicitly.
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
}

extension WebRepository {
    /// Performs an asynchronous API call and decodes the response.
    /// - Parameters:
    ///   - endpoint: The endpoint to call.
    ///   - httpCodes: The expected range of HTTP status codes for success.
    /// - Returns: A decoded response of type `T`.
    func call<T: Codable>(endpoint: APICall, httpCodes: HTTPCodes = .success) async throws -> T {
        let request = try await endpoint.urlRequest(baseURL: baseURL)
        
        let (data, response) = try await session.data(for: request)
        
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.unexpectedResponse
        }
        
        guard httpCodes.contains(code) else {
            throw APIError.httpCode(code)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
    
    /// Performs an asynchronous API call without expecting a response body.
    /// - Parameters:
    ///   - endpoint: The endpoint to call.
    ///   - httpCodes: The expected range of HTTP status codes for success.
    func callNoResponse(endpoint: APICall, httpCodes: HTTPCodes = .success) async throws {
        let request = try await endpoint.urlRequest(baseURL: baseURL)
        
        let (_, response) = try await session.data(for: request)
        
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.unexpectedResponse
        }
        
        guard httpCodes.contains(code) else {
            throw APIError.httpCode(code)
        }
    }
    
    /// Performs an asynchronous API call and returns the raw response data.
    /// - Parameters:
    ///   - endpoint: The endpoint to call.
    ///   - httpCodes: The expected range of HTTP status codes for success.
    ///   - isRetry: A boolean indicating whether this is a retry attempt.
    /// - Returns: Raw response data.
    func callGetData(endpoint: APICall, httpCodes: HTTPCodes = .success, isRetry: Bool = false) async throws -> Data {
        
        let request = try await endpoint.urlRequest(baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        guard let _ = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.unexpectedResponse
        }
        return data
    }
}

extension URLSession {
    /// Provides a URLSession instance for mocked responses only.
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

/// A property wrapper for ensuring the base URL ends with a slash.
@propertyWrapper struct BaseURLSlashed {
    /// The base URL string.
    var wrappedValue: String

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}
