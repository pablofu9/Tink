//
//  ChatDetailView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct ChatDetailView: View {
    
    // MARK: - PROPERTIES
    var chat: Chat
    let userNotUs: User
    @State private var text: String = ""
    @EnvironmentObject var chatManager: ChatManager
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState var focus
    let height: Double = 130
    // Coordinator for navigation
    @Environment(Coordinator<MainCoordinatorPages>.self) private var coordinator

    // MARK: - BODY
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScrollViewReader { reader in
                    ScrollView {
                        VStack {
                            ForEach(chatManager.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .safeAreaInset(edge: .top) {
                            EmptyView()
                                .frame(height: height)
                        }
                        .safeAreaTopPadding(proxy: proxy)
                        .overlay(alignment: .top) {
                            headerView(proxy)
                        }
                    }
                    .onAppear {
                        scrollToBottom(reader)
                    }
                    .padding(.bottom, keyboardObserver.keyboardHeight > 0 ? keyboardObserver.keyboardHeight + 65 : 110)
                    .onChange(of: chatManager.messages) {
                        scrollToBottom(reader)
                    }
                    .onChange(of: keyboardObserver.keyboardHeight) {
                        scrollToBottom(reader)
                    }
                    .coordinateSpace(name: "SCROLL")
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarHidden(true)
            .onTapGesture {
                focus = false
            }
            .overlay(alignment: .bottom) {
                textfieldCustom
                    .padding(.bottom, proxy.safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.bgColor)
        .onAppear {
            chatManager.observeMessages(for: chat.id) 
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollToBottom(nil)
            }
        }
        .onDisappear {
            Task {
                if chatManager.messages.isEmpty {
                    try await chatManager.deleteChat(chat)
                   
                }
                try await chatManager.changeReadMessage(chat: chat)
            }
            chatManager.stopObservingMessages()
        }
    }
}

// MARK: - SUBVIEWS
extension ChatDetailView {
    
    /// Header view
    @ViewBuilder
    private func headerView(_ proxy: GeometryProxy) -> some View {
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            HStack(spacing: 20) {
                BackButton(action: {
                    coordinator.pop()
                })
                
                imageView
                
                Text(userNotUs.name)
                    .foregroundStyle(ColorManager.defaultWhite)
                    .font(.custom(CustomFonts.regular, size: 17))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 10)
            .padding(.top, proxy.safeAreaInsets.top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height)
            .background(ColorManager.primaryBasicColor)
            .offset(y: -minY)
        }
        .frame(height: height)
    }
    
    /// Profile image view
    @ViewBuilder
    private var imageView: some View {
        if let userImage = userNotUs.profileImageURL, let url = URL(string: userImage) {
            WebImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                case .failure:
                    LoadingView()
                @unknown default:
                    LoadingView()
                }
            }
            .resizable()
            .frame(width: 55, height: 55)
            .background(ColorManager.defaultWhite)
            .clipShape(Circle())
            .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
        } else {
            Image(.noProfileIcon)
                .resizable()
                .frame(width: 45, height: 45)
                .padding(5)
                .background(ColorManager.defaultWhite)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
        }
    }
    
    /// Text field custom
    @ViewBuilder
    private var textfieldCustom: some View {
        HStack {
            TextField("", text: $text, prompt: Text("Escribe aquí"))
                .focused($focus)
                .padding(15)
                .background(ColorManager.secondaryGrayColor)
                .clipShape(Capsule())
            Button {
                Task {
                    if !text.isEmpty, let userUs = UserDefaults.standard.userSaved {
                        try await chatManager.sendMessage(text: text, chatId: chat.id, senderId: userUs.id)
                        text = ""
                    }
                }
            } label: {
                Image(.sendIcon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(ColorManager.defaultWhite)
                    .padding(10)
                    .background(ColorManager.primaryBasicColor)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 60)
    }
    
    // MARK: - Scroll to bottom function
    private func scrollToBottom(_ reader: ScrollViewProxy?) {
        guard let lastMessageId = chatManager.messages.last?.id else { return }
        DispatchQueue.main.async {
            withAnimation {
                reader?.scrollTo(lastMessageId, anchor: .top)
            }
        }
    }
}

#Preview {
    @Previewable @State  var coordinator = Coordinator<MainCoordinatorPages>()

    let chat = [Chat(id: "1", messages: [Message(id: "1", text: "Ultimo mensaje", received: true, timestamp: Date(), users: User.sampleUser.id)], users: [User.userDefaultSample.id])]
    let user = User.sampleUser
    ChatDetailView(chat: chat.first!, userNotUs: user)
        .environmentObject(ChatManager())
        .environment(coordinator)
}


