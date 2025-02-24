//
//  ProfileView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    // MARK: - VIEW PROPERTIES
    let proxy: GeometryProxy
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    @EnvironmentObject var databaseManager: FSDatabaseManager
    
    // MARK: - TOGGLE VIEW
    @State var toggleView: Bool = false
    
    // MARK: - CONTROL MODIFY SKILL
    @State var selectedSkillToModify: Skill?
    
    
    // MARK: - BODY
    var body: some View {
        content
    }
}

// MARK: - SUBVIEWS
extension ProfileView {
    
    /// Content view
    @ViewBuilder
    private var content: some View {
        ZStack(alignment: .top) {
            ScrollView {
                if let _ = UserDefaults.standard.userSaved {
                    LazyVStack(alignment: .leading,spacing: 20) {
                        skillsView
                        informationView
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
        .sheet(item: $selectedSkillToModify, onDismiss: {
            Task {
                databaseManager.loading = true
                defer { databaseManager.loading = false }
                try await Task.sleep(nanoseconds: 2_000_000_000)
                try await databaseManager.syncSkills()
            }
        }) { skill in
            NewSkillView(isMiddlePressed: .constant(false), skill: skill)
        }
        .onDisappear {
            databaseManager.currentIndex = 0
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.bgColor)
    }
    
    /// Header View
    @ViewBuilder
    private func profileHeader(_ proxy: GeometryProxy) -> some View {
        let height = Measures.kTopShapeHeightSmaller
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let dynamicHeight = max(105, max(height + (minY < 0 ? minY : 0), 0))
            let textOffsetY = max(-22, min(0, minY * 0.2))
            let progressShape = min(max((minY + 70) / 40, 0), 1)
            ZStack(alignment: .trailing) {
                TopShape(progress: progressShape)
                    .frame(maxWidth: .infinity)
                    .frame(height: dynamicHeight, alignment: .top)
                    .foregroundStyle(ColorManager.primaryBasicColor)
                Text("PROFILE_HEADER".localized)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(CustomFonts.bold, size: 30))
                    .foregroundStyle(ColorManager.defaultWhite)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .offset(y: -textOffsetY)
            }
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
    
    /// Skills view
    @ViewBuilder
    private var skillsView: some View {
        if !databaseManager.skillsSaved.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text("PROFILE_YOUR_SKILLS".localized)
                    .font(.custom(CustomFonts.bold, size: 25))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                Button {
                    if databaseManager.currentIndex <= databaseManager.skillsSaved.count {
                        selectedSkillToModify = databaseManager.skillsSaved[databaseManager.currentIndex]
                    }
                } label: {
                    SkillCarouselView(skills: $databaseManager.skillsSaved, currentIndex: $databaseManager.currentIndex)
                }
            }
        }

    }
    
    /// Information view
    @ViewBuilder
    private var informationView: some View {
        if let profileSaved = UserDefaults.standard.userSaved {
            VStack(alignment: .leading, spacing: 15) {
                Text("PROFILE_YOUR_INFORMATION".localized)
                    .font(.custom(CustomFonts.bold, size: 25))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                rowView(name: "person.fill", text: "NAME".localized, udText: "\(profileSaved.name)")
                rowView(name: "envelope.fill", text: "LOGIN_EMAIL".localized, udText: profileSaved.email)
            }
            .padding(.horizontal, Measures.kHomeHorizontalPadding)
        }
    }

}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = FSDatabaseManager()
        UserDefaults.standard.userSaved = User.sampleUser
     //   mockManager.skillsSaved = Skill.sampleArray
        return GeometryReader { proxy in
            ProfileView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
