//
//  CoordinatorStack.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import SwiftUI

struct CoordinatorStack<AuthCoordinatorPages: Coordinatable>: View {
    
    let root: AuthCoordinatorPages
    @State private var coordinator = Coordinator<AuthCoordinatorPages>()
    @EnvironmentObject var databaseManager: FSDatabaseManager

    init(_ root: AuthCoordinatorPages) {
        self.root = root
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root
                .navigationDestination(for: AuthCoordinatorPages.self) { $0 }
                .sheet(item: $coordinator.sheet) { $0 }
                .fullScreenCover(item: $coordinator.fullScreenCover) { $0 }
        }
        .environment(coordinator)
    }
}
