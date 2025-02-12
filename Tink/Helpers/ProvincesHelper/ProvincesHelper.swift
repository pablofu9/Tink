//
//  ProvincesHelper.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation

@MainActor
class ProvincesHelper: ObservableObject {
    
    let provincesService = ProvincesService()
    
    @Published var communities: [AutonomousCommunity] = []
    @Published var provinces: [Province] = []
    @Published var towns: [Town] = []
       
    func loadCommunities() {
        Task {
            do {
                // 1. Fetch commnunities
                let fetchedCommunities = try await provincesService.fectchProvinces()
                //                let mockTowns = [
                //                      Town(parentCode: "04", code: "1", label: "Almería"),
                //                      Town(parentCode: "04", code: "2", label: "Roquetas de Mar"),
                //                      Town(parentCode: "04", code: "3", label: "Adra")
                //                  ]
                //
                //                  let mockProvinces = [
                //                      Province(parentCode: "01", code: "04", label: "Almería", towns: mockTowns),
                //                      Province(parentCode: "02", code: "06", label: "Granada", towns: mockTowns)
                //                  ]
                //
                //                  let mockCommunities = [
                //                      AutonomousCommunity(parentCode: "0", label: "Andalucía", code: "01", provinces: mockProvinces),
                //                      AutonomousCommunity(parentCode: "0", label: "Cataluña", code: "09", provinces: mockProvinces)
                //                  ]
                self.communities = fetchedCommunities
            } catch {
                print("Error al cargar las comunidades: \(error.localizedDescription)")
            }
        }
    }
    
    func getProvinces(comunity: AutonomousCommunity) {
        self.provinces = comunity.provinces
    }
    
    func removeProvinces() {
        self.provinces = []
    }
    
    func removeTowns() {
        self.towns = []
    }
    
    func getTowns(province: Province) {
        self.towns = province.towns
    }
}

// MARK: - MOCK
extension ProvincesHelper {
    
    
}
