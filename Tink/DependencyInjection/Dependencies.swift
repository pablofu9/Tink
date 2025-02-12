//
//  Dependencies.swift
//  snnemployee
//
//  Created by Pablo Fuertes on 11/7/24.
//

import Foundation

final class Dependencies: Sendable {
    
    @MainActor static var shared: Dependencies = .init()
    
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }
    
    
    /// Function that provides the dependencies on app init
    func provideDependencies(testMode: Bool = true) {
        provincesRepo()
    }
}

// MARK: HOME DEPENDENCY
extension Dependencies {
    private func provincesRepo(testMode: Bool = false) {
        if testMode {
            @Provider var provincesRepo = MockProvincesWebRepo() as ProvincesWebRepo
        } else {
            let baseUrl = "https://bag-it-321fd.web.app/"
            @Provider var provincesRepo = RealProvincesWebRepo(session: session, baseURL: baseUrl) as ProvincesWebRepo
        }
    }
}

