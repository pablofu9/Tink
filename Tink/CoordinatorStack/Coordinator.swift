//
//  Coordinator.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import Foundation
import SwiftUI

@Observable
class Coordinator<AuthCoordinatorPages: Coordinatable> {
    
    var path: NavigationPath = NavigationPath()
    var sheet: AuthCoordinatorPages?
    var fullScreenCover: AuthCoordinatorPages?
    
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
    
    func push(_ page: AuthCoordinatorPages, type: PushType = .link) {
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


@Observable
final class MockCoordinator: Coordinator<AuthCoordinatorPages> {
    @MainActor static let shared = MockCoordinator()
    
    override init() {
        super.init()
    }

    override func push(_ page: AuthCoordinatorPages, type: Coordinator<AuthCoordinatorPages>.PushType = .link) {
        print("Navigating to: \(page)")
    }
}
