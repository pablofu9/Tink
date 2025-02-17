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
            .onAppear {
                Task {
                    try await databaseManager.checkIfUserExistInDatabase()
                }
            }
            .fullScreenCover(isPresented: $isMiddlePressed) {
                NewSkillView(isMiddlePressed: $isMiddlePressed)
            }
            .overlay {
                if databaseManager.loading {
                    LoadingView()
                }
            }
    }
}

// MARK: - SUBVIEWS
extension MainView {
    
    // Get selected view from tab bar
    @ViewBuilder
    private func getSelectedView(_ proxy: GeometryProxy) -> some View {
        switch activeTab {
        case .home:
            HomeView(proxy: proxy)
        case .settings:
            EmptyView()
        case .chat:
            EmptyView()
        case .profile:
            ProfileView(proxy: proxy)
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
        }
        .overlay {
            if databaseManager.goCompleteProfile {
                CompleteProfileView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainView()
        .environmentObject(FSDatabaseManager())
        .environment(AuthenticatorManager())
}

