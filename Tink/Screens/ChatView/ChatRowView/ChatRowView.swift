//
//  ChatRowView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct ChatRowView: View {
    
    let chat: Chat
    @EnvironmentObject var databaseManager: FSDatabaseManager
    @State var user: User?
    // Coordinator for navigation
    @Environment(Coordinator<MainCoordinatorPages>.self) private var coordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                imageView
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(user?.name ?? "")
                            .font(.custom(CustomFonts.bold, size: 17))
                            .foregroundStyle(ColorManager.primaryGrayColor)
                        Spacer()
                        if let lastMessageNotUs = chat.messages.last(where: {$0.users != UserDefaults.standard.userSaved?.id}) {
                            
                            Text("\(lastMessageNotUs.timestamp.formatted(.dateTime.hour().minute()))")
                                .font(.custom(CustomFonts.regular, size: 16))
                                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
                        }
                    }
                    Text(user?.email ?? "")
                        .font(.custom(CustomFonts.regular, size: 16))
                        .foregroundStyle(ColorManager.primaryGrayColor)
                    HStack {
                        if let lastMessageNotUs = chat.messages.last(where: {$0.users != UserDefaults.standard.userSaved?.id}) {
                            
                            Text(lastMessageNotUs.text)
                                .font(.custom(CustomFonts.regular, size: 16))
                                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
                            Spacer()
                            
                        }
                    }
                }
            }
            .padding(.horizontal, Measures.kHomeHorizontalPadding)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 2)
                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.3))
        }
        .onTapGesture {
            if let user {
                coordinator.push(.chatDetail(chat: chat, user: user))
            }
        }
        .onAppear {
            Task {
                if let idNotUs = chat.users.first(where: {$0 != UserDefaults.standard.userSaved?.id}) {
                    user = try await databaseManager.getUser(userID: idNotUs)
                }
            }
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let user, let userImage = user.profileImageURL, let url = URL(string: userImage) {
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
            .frame(width: 60, height: 60)
            .background(ColorManager.defaultWhite)
            .clipShape(Circle())
            .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
        } else {
            Image(.noProfileIcon)
                .resizable()
                .frame(width: 50, height: 50)
                .padding(5)
                .background(ColorManager.defaultWhite)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
        }
    }
}



#Preview {
    @Previewable @State  var coordinator = Coordinator<MainCoordinatorPages>()

    let chat = [Chat(id: "1", messages: [Message(id: "1", text: "Ultimo mensaje", received: true, timestamp: Date(), users: User.sampleUser.id)], users: [User.sampleUser.id])]
    UserDefaults.standard.userSaved = User.userDefaultSample
    return ChatRowView(chat: chat.first!)
        .environment(coordinator)
        .environmentObject(FSDatabaseManager())
}
