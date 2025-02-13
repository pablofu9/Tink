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
    
    // MARK: - CAROUSEL CONTROLLER
    @State private var currentIndex: Int = 0
    
    // MARK: - TOGGLE VIEW
    @State var toggleView: Bool = false
    
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                if let _ = UserDefaults.standard.userSaved {
                    LazyVStack(alignment: .leading,spacing: 20) {
                        skillsView
                        informationView
                        logoutButton
                            .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: Measures.kTopShapeHeightSmaller - 40)
                    }
                    .safeAreaInset(edge: .bottom) {
                        EmptyView()
                            .frame(height: Measures.kTabBarHeight + 60)
                    }
                    .safeAreaTopPadding(proxy: proxy)
                    .overlay(alignment: .top) {
                        profileHeader(proxy)
                    }
                }
            }
            .coordinateSpace(name: "SCROLL")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.bgColor)
    }
}

extension ProfileView {
    
    /// Header View
    @ViewBuilder
    private func profileHeader(_ proxy: GeometryProxy) -> some View {
        let height = Measures.kTopShapeHeightSmaller
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.6))
            let dynamicHeight = max(height + (minY < 0 ? minY : 0), 0)
            let interpolatedOpacity = max(0, min(1, 1 + progress))

            ZStack(alignment: .leading) {
              
                topShape(dynamicHeight)
                    .frame(height: dynamicHeight)

                Text("PROFILE_HEADER".localized)
                    .font(.custom(CustomFonts.bold, size: 30))
                    .foregroundStyle(ColorManager.defaultWhite)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .opacity(interpolatedOpacity)
            }
            .opacity(interpolatedOpacity)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: dynamicHeight, alignment: .top)
            .offset(y: -minY)
        }
        .frame(height: height)
    }
    
    /// Top shape view
    @ViewBuilder
    private func topShape(_ curvedHeight: CGFloat) -> some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: curvedHeight, alignment: .top)
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
        }
    }
    
    /// Skills view
    @ViewBuilder
    private var skillsView: some View {
        if !UserDefaults.standard.skillsSaved.isEmpty {
            let filteredSkills = UserDefaults.standard.skillsSaved.filter { skill in
                return skill.user.id == UserDefaults.standard.userSaved?.id
            }
            if !filteredSkills.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("PROFILE_YOUR_SKILLS".localized)
                        .font(.custom(CustomFonts.bold, size: 25))
                        .foregroundStyle(ColorManager.primaryGrayColor)
                        .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    SkillCarouselView(skills: filteredSkills, selectedIndex: $currentIndex)
                }
            }
        }
    }
    
    @ViewBuilder
    private var informationView: some View {
        if let profileSaved = UserDefaults.standard.userSaved {
            VStack(alignment: .leading, spacing: 15) {
                Text("PROFILE_YOUR_INFORMATION".localized)
                    .font(.custom(CustomFonts.bold, size: 25))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                rowView(name: "person.fill", text: "NAME".localized, udText: "\(profileSaved.name) \(profileSaved.surname)")
                rowView(name: "envelope.fill", text: "LOGIN_EMAIL".localized, udText: profileSaved.email)
                rowView(name: "map.fill", text: "LOCALITY".localized, udText: "\(profileSaved.locality), \(profileSaved.province)")
            }
            .padding(.horizontal, Measures.kHomeHorizontalPadding)
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = FSDatabaseManager()
        UserDefaults.standard.userSaved = User.sampleUser
        UserDefaults.standard.skillsSaved = Skill.sampleArray
        return GeometryReader { proxy in
            ProfileView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
