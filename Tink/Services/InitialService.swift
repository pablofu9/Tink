//
//  InitialService.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation

actor InitialService {
    
    func initialSynch() async throws {
        await Dependencies.shared.provideDependencies()
    }
}
