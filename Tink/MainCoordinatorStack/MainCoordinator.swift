//
//  MainCoordinator.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 25/2/25.
//


import Foundation
import SwiftUI

@Observable
class MainCoordinator<MainCoordinatorPages: Coordinatable> {
    
    var path: NavigationPath = NavigationPath()
    var sheet: MainCoordinatorPages?
    var fullScreenCover: MainCoordinatorPages?
    
    enum PushType {
        case link
        case sheet
        case fullScreenCover
    }
    
    enum PopType {
        case link(last: Int)
        case sheet
        case fullScreenCover
    }
    
    func push(_ page: MainCoordinatorPages, type: PushType = .link) {
        switch type {
        case .link:
            path.append(page)
        case .sheet:
            sheet = page
        case .fullScreenCover:
            fullScreenCover = page
        }
    }
    
    func pop(type: PopType = .link(last: 1)) {
        switch type {
        case .link(let last):
            path.removeLast(last)
        case .sheet:
            sheet = nil
        case .fullScreenCover:
            fullScreenCover = nil
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}


