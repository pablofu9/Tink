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
    @State var showImageView: Bool = false
    @State var showImageSourceActionSheet: Bool = false
    @Environment(AuthenticatorManager.self) private var authenticatorManager

    // MARK: - MATCHED GEOMETRY EFFECT
    @Namespace var animation
    
    var body: some View {
        content
            .fullScreenCover(isPresented: $isMiddlePressed) {
                NewSkillView(isMiddlePressed: $isMiddlePressed)
            }
            .overlay {
                if databaseManager.loading {
                    LoadingView()
                }
            }
            .overlay {
                if showImageView {
                    if let imageURL = UserDefaults.standard.userSaved?.profileImageURL {
                        FullImageView(image: imageURL, editAction: {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showImageView = false
                                showImageSourceActionSheet = true
                            }
                        }, backAction: {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showImageView = false
                            }
                        }, nameSpace: animation)
                    } else {
                        FullImageView(image: nil, editAction: {
                            withAnimation {
                                showImageView = false
                                showImageSourceActionSheet = true
                            }
                        }, backAction: {
                            withAnimation {
                                showImageView = false
                            }
                        }, nameSpace: animation)
                    }
                
                }
            }
            .onAppear {
                Task {
                    databaseManager.handleUserInFirestore()
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
            HomeView(proxy: proxy, activeTab: $activeTab)
        case .settings:
            SettingsView(proxy: proxy, showImageSourceActionSheet: $showImageSourceActionSheet, showImageBig: $showImageView, nameSpace: animation)
        case .chat:
            ChatsView(proxy: proxy)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainView()
        .environmentObject(FSDatabaseManager())
        .environment(AuthenticatorManager())
}

