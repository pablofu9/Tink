//
//  MainCoordinatorStack.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 25/2/25.
//

import Foundation
import SwiftUI

struct MainCoordinatorStack<MainCoordinatorPages: Coordinatable>: View {
    
    let root: MainCoordinatorPages
    @State private var coordinator = Coordinator<MainCoordinatorPages>()
    
    init(_ root: MainCoordinatorPages) {
        self.root = root
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root
                .navigationDestination(for: MainCoordinatorPages.self) { $0 }
                .sheet(item: $coordinator.sheet) { $0 }
                .fullScreenCover(item: $coordinator.fullScreenCover) { $0 }
        }
        .environment(coordinator)
    }
}
