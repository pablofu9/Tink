//
//  ChatsView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import SwiftUI

struct ChatsView: View {
    
    @EnvironmentObject var chatManager: ChatManager
    let proxy: GeometryProxy
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if !chatManager.chats.isEmpty {
                        ForEach(chatManager.chats) { chat in
                            ChatRowView(chat: chat)
                        }
                    } else {
                        EmptyContentView(title: "CHAT_NO_CHATS".localized, image: .noChatsIcon, frame: 200)
                            .padding(.top, UIScreen.main.bounds.size.height / 7)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .safeAreaInset(edge: .bottom) {
                    EmptyView()
                        .frame(height: Measures.kTabBarHeight + 70)
                }
                .safeAreaInset(edge: .top) {
                    EmptyView()
                        .frame(height: 70)
                }
                .safeAreaTopPadding(proxy: proxy)
                .overlay(alignment: .top) {
                    headerView
                }
            }
            .coordinateSpace(name: "SCROLL")
        }
        .onAppear {
            Task {
                chatManager.observeChats()
            }
        }
        .onDisappear {
            chatManager.stopObservingChats()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorManager.bgColor)
    }
}

extension ChatsView {
    
    /// Header View
    @ViewBuilder
    private var headerView: some View {
        let height: Double = 90
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            VStack(alignment: .leading) {
                Text("Chats")
                    .font(.custom(CustomFonts.bold, size: 30))
                    .foregroundStyle(ColorManager.defaultWhite)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .padding(.top, proxy.safeAreaInsets.top)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
            .background(ColorManager.primaryBasicColor)
            .offset(y: -minY)
        }
        .frame(height: height)
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = ChatManager()
        mockManager.chats = [Chat(id: "1", messages: [], users: [User.sampleUser.id])]
        UserDefaults.standard.userSaved = User.userDefaultSample

        return GeometryReader { proxy in
            ChatsView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .environmentObject(FSDatabaseManager())
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
