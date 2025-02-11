//
//  MainView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 7/2/25.
//

import SwiftUI

//
//  MainView.swift
//  BagIt
//
//  Created by Pablo Fuertes ruiz on 2/1/25.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - PROPERTIES
    @State private var activeTab: TabModel = .home
    @State private var isMiddlePressed: Bool = false
    @EnvironmentObject var databaseManager: FSDatabaseManager

    var body: some View {
        content
    }
}

extension MainView {
    
    @ViewBuilder
    private func getSelectedView(_ proxy: GeometryProxy) -> some View {
        switch activeTab {
        case .home:
            HomeView(proxy: proxy)
        case .settings:
            SettingsView()
        case .chat:
            EmptyView()
        case .profile:
            EmptyView()
        }
    }
    
    /// Content view
    @ViewBuilder
    private var content: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom, content: {
                getSelectedView(proxy)
                ZStack {
                    TabBarView(activeTab: $activeTab, isMiddlePressed: $isMiddlePressed)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            })
            .ignoresSafeArea()
            .overlay {
                if databaseManager.loading {
                    LoadingView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainView()
        .environmentObject(FSDatabaseManager())
}

