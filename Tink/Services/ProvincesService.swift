//
//  ProvincesService.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation

actor ProvincesService {
    
    func fectchProvinces() async throws -> [AutonomousCommunity] {
        @Inject var provincesRepo: ProvincesWebRepo
        return try await provincesRepo.getComunities()
    }
}

