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
    
    var chat: Chat
    let userNotUs: User
    @State private var text: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var chatManager: ChatManager
    @StateObject private var keyboardObserver = KeyboardObserver()

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
                        .safeAreaTopPadding(proxy: proxy)
                        .overlay(alignment: .top) {
                            headerView(proxy)
                        }
                        .onChange(of: keyboardObserver.keyboardHeight) {
                            print("\(keyboardObserver.keyboardHeight)")
                        }
                    }
                    .padding(.bottom, keyboardObserver.keyboardHeight > 0 ? keyboardObserver.keyboardHeight + 65 : 125)
                    .onChange(of: chatManager.messages) {
                        scrollToBottom(reader)
                    }
                    .coordinateSpace(name: "SCROLL")
                }
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
            chatManager.observeMessages(for: chat.id) // Escucha los mensajes solo de este chat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollToBottom(nil)
            }
        }
        .onDisappear {
            chatManager.stopObservingMessages()
        }
    }
}

extension ChatDetailView {
    
    @ViewBuilder
    private func headerView(_ proxy: GeometryProxy) -> some View {
        let height: Double = 130
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            HStack(spacing: 5) {
                BackButton(action: {
                    dismiss()
                })
                imageView
                    .padding(.trailing, 10)
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
                .frame(width: 55, height: 55)
                .background(ColorManager.defaultWhite)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
        }
    }
    
    @ViewBuilder
    private var textfieldCustom: some View {
        HStack {
            TextField("", text: $text, prompt: Text("Escribe aquí"))
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
            reader?.scrollTo(lastMessageId, anchor: .top)
        }
    }
}

#Preview {
    let chat = [Chat(id: "1", messages: [Message(id: "1", text: "Ultimo mensaje", received: true, timestamp: Date(), users: User.sampleUser.id)], users: [User.userDefaultSample.id])]
    let user = User.sampleUser
    ChatDetailView(chat: chat.first!, userNotUs: user)
        .environmentObject(ChatManager())
}

import SwiftUI
import Combine

// Observador para el teclado
class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observa el cambio en el teclado
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return keyboardFrame.height
                }
                return 0
            }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)
    }
}
