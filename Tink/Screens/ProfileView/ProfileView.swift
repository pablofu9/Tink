//
//  ProfileView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import SwiftUI

struct ProfileView: View {
    
    // MARK: - VIEW PROPERTIES
    let proxy: GeometryProxy
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    @EnvironmentObject var databaseManager: FSDatabaseManager

    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            profileHeader
            ScrollView {
                if let profileSaved = UserDefaults.standard.userSaved {
                    LazyVStack(alignment: .leading,spacing: 20) {
                        
                        rowView(name: "person.fill", text: "NAME".localized, udText: profileSaved.name)
                        rowView(name: "envelope.fill", text: "LOGIN_EMAIL".localized, udText: profileSaved.email)
                        rowView(name: "person.text.rectangle.fill", text: "DNI_NIE".localized, udText: profileSaved.dni)
                        
                        rowView(name: "map.fill", text: "LOCALITY".localized, udText: "\(profileSaved.locality), \(profileSaved.province)")
                    }
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                }
            }
            .padding(.bottom, Measures.kTabBarHeight + 40)
            .padding(.top, Measures.kTopShapeHeightSmaller)
        }
        .overlay(alignment: .bottom) {
            logoutButton
                .padding(.bottom, Measures.kTabBarHeight + 40)
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.bgColor)
        .onAppear {
            Task {
                try await databaseManager.checkIfUserExistInDatabase()
            }
        }
    }
}

extension ProfileView {
    
    /// Header View
    @ViewBuilder
    private var profileHeader: some View {
        ZStack(alignment: .leading) {
            topShape
            Text("PROFILE_HEADER".localized)
                .font(.custom(CustomFonts.bold, size: 30))
                .foregroundStyle(ColorManager.defaultWhite)
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Top shape view
    @ViewBuilder
    private var topShape: some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: Measures.kTopShapeHeightSmaller, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
    }
    
    /// Custom Row View
    @ViewBuilder
    private func rowView(name: String, text: String, udText: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Image(systemName: name)
                    .foregroundStyle(ColorManager.primaryBasicColor)
                Text(text)
                    .font(.custom(CustomFonts.regular, size: 18))
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.6))
            }
          
            Text(udText)
                .font(.custom(CustomFonts.regular, size: 19))
                .foregroundStyle(ColorManager.defaultBlack)
            Divider()
        }
    }
    
    /// Loogut button
    @ViewBuilder
    private var logoutButton: some View {
        Button {
            Task {
                try authenticatorManager.signOut()
            }
            
        } label: {
            HStack {
                Image(systemName: "door.left.hand.open")
                    .foregroundStyle(ColorManager.cancelColor)
                Text("SETTINGS_LOGOUT".localized)
                    .font(.custom(CustomFonts.regular, size: 19))
                    .foregroundStyle(ColorManager.cancelColor)
            }
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(ColorManager.cancelColor)
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(ColorManager.bgColor)
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = FSDatabaseManager()
        mockManager.categories = [
            FSCategory(id: "1", name: "Albañilería", is_manual: true),
            FSCategory(id: "2", name: "Carpintería", is_manual: true),
            FSCategory(id: "3", name: "Clases online", is_manual: false),
        ]
        
        UserDefaults.standard.userSaved = User(id: "1", name: "Juan", email: "juan@Gmail.com", dni: "877282", community: "Madrid", province: "Madrid", locality: "Toledo")
        return GeometryReader { proxy in
            ProfileView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .environmentObject(FSDatabaseManager())
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
