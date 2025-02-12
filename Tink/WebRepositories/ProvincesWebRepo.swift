//
//  ProvincesWebRepo.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//


import Foundation
import SwiftUI

protocol ProvincesWebRepo: WebRepository {
    
    func getComunities() async throws -> [AutonomousCommunity]
}

/// A concrete implementation of `EmergenciesWebRepository` for making real network requests.
struct RealProvincesWebRepo: ProvincesWebRepo {
    
    /// The URLSession used for network requests.
    var session: URLSession
    
    /// The base URL for the API.
    @BaseURLSlashed private(set) var baseURL: String
    
    /// Initializes a `RealEmergenciesWebRepository` instance.
    /// - Parameters:
    ///   - session: The URLSession to use for network requests.
    ///   - baseURL: The base URL for the API.
    init(session: URLSession, baseURL: String){
        self.session = session
        self.baseURL = baseURL
    }
    
    // MARK: - API endpoints
    /// Fetch home result
    func getComunities() async throws -> [AutonomousCommunity]{
        return try await call(endpoint: API.getComunities)
    }
}

struct MockProvincesWebRepo: ProvincesWebRepo {
    
    var session: URLSession = .mockedResponsesOnly
    
    var baseURL: String = "https://test.com"
    
    func getComunities() async throws -> FoodModelContainer {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Crear datos de ejemplo mock
        let mockProvinces: [AutonomousCommunity] = [
            AutonomousCommunity(
                parentCode: "0",
                label: "Andalucía",
                code: "01",
                provinces: [
                    Province(
                        parentCode: "01",
                        code: "04",
                        label: "Almería",
                        towns: [
                            Town(parentCode: "04", code: "0", label: "Abla"),
                            Town(parentCode: "04", code: "5", label: "Abrucena")
                        ]
                    )
                ]
            )
        ]
        return mockProvinces
    }
}

// MARK: - API endpoints
extension RealProvincesWebRepo {
    enum API {
        case getComunities
    }
}

extension RealProvincesWebRepo.API: APICall {
    
    var path: String {
        switch self {
        case .getComunities:
            return "/provinces.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getComunities:
            return .get
        }
    }
    
    var authenticated: Bool {
        switch self {
        case .getComunities:
            return true
        }
    }
    
    func headers() async throws -> [String : String]? {
        switch self {
        case .getComunities:
            return [:]
        }
    }
    
    func body() throws -> Data? {
        switch self {
        case .getComunities:
            return nil
        }
    }
}
