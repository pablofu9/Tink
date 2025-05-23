//
//  SkillDetailView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 18/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SkillDetailView: View {
    
    // SKILL PROPERTY
    let skill: Skill
    // Chat manager
    @EnvironmentObject var chatManager: ChatManager
    // Active tab
    @Binding var activeTab: TabModel
    // Coordinator navigation
    @Environment(Coordinator<MainCoordinatorPages>.self) private var coordinator

    // MARK: - BODY
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .top) {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading ,spacing: 15) {
                        nameAndDesc(skill.name, skill.description)
                        customDivider
                        infoView(textHeader: "INFORMATION".localized)
                        customDivider
                        userInfoView("SKILL_DETAIL_INFO".localized)
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: UIScreen.main.bounds.size.height * 0.25)
                    }
                    .safeAreaInset(edge: .bottom) {
                        EmptyView()
                            .frame(height:  UIScreen.main.bounds.size.height * 0.35)
                    }
                    .safeAreaTopPadding(proxy: reader)
                    .overlay(alignment: .top) {
                        headerView(reader)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .coordinateSpace(name: "SCROLL")
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden()
            .navigationBarHidden(true)
            .ignoresSafeArea()
        }
  
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorManager.bgColor)
    }
}


// MARK: - SUBVIEWS
extension SkillDetailView {
    
    /// Header view
    @ViewBuilder
    private func headerView(_ reader: GeometryProxy) -> some View {
        let height = UIScreen.main.bounds.size.height * 0.3
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.6))
            let dynamicHeight = height + minY
            let clampedHeight = max(dynamicHeight, 0)
            let interpolatedOpacity = max(0, min(1, 1 + progress))
            let invertedOpacity = 1 - interpolatedOpacity

            ZStack(alignment: .top) {
                imageView(clampedHeight)

                backIcon
                    .padding(.top, reader.safeAreaInsets.top)
                    .padding(.leading, Measures.kHomeHorizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .offset(y: -minY)
            .frame(maxWidth: .infinity)
            .frame(height: clampedHeight)
            .opacity(interpolatedOpacity)

            headerWhenScroll(invertedOpacity, offset: minY, height: height, proxy: reader)
        }
        .frame(height: height)
    }
    
    @ViewBuilder
    private func headerWhenScroll(_ opacity: CGFloat, offset: CGFloat, height: CGFloat, proxy: GeometryProxy) -> some View {
        ZStack {
            ColorManager.bgColor
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.2),radius: 2, x: 0, y: 2)
            ZStack {
                backIcon
                    .padding(.leading, Measures.kHomeHorizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(skill.name)
                    .padding(.horizontal, 70)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.bold, size: 17))
            }
            .padding(.top, proxy.safeAreaInsets.top - 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height / 2.7)
        .offset(y: -offset)
        .opacity(opacity)
    }
    
    /// Image view
    @ViewBuilder
    private func imageView(_ imageHeight: CGFloat) -> some View {
        if let imageUrl = skill.category.image_url, let url = URL(string: imageUrl) {
            WebImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .frame(height: imageHeight)
                case .failure:
                    LoadingView()
                        .frame(height: imageHeight)
                @unknown default:
                    LoadingView()
                        .frame(height: imageHeight)
                }
            }
        } else {
            ColorManager.primaryGrayColor.opacity(0.5)
            
        }
    }
    
    /// Back Icon
    @ViewBuilder
    private var backIcon: some View {
        BackButton(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                coordinator.pop()
            }
        })
    }
    
    /// Field view
    @ViewBuilder
    private func fieldView(textHeader: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(textHeader)
                .font(.custom(CustomFonts.regular, size: 15))
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
            Text(text)
                .font(.custom(CustomFonts.regular, size: 16))
                .foregroundStyle(ColorManager.primaryGrayColor)
        }
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
    }
    
    /// Name and description
    @ViewBuilder
    private func nameAndDesc(_ name: String, _ descr: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(name)
                .font(.custom(CustomFonts.bold, size: 17))
                .foregroundStyle(ColorManager.primaryGrayColor)
            Text(descr)
                .font(.custom(CustomFonts.regular, size: 16))
                .foregroundStyle(ColorManager.primaryGrayColor)
        }
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
    }
    
    /// Custom divider
    @ViewBuilder
    private var customDivider: some View {
        Rectangle()
            .fill(
                LinearGradient(colors: [ColorManager.primaryBasicColor, ColorManager.primaryBasicColor.opacity(0.7), ColorManager.primaryBasicColor.opacity(0.5)], startPoint: .top, endPoint: .bottom)
            )
            .frame(maxWidth: .infinity)
            .frame(height: 20)
           
    }
    
    /// Info View
    @ViewBuilder
    private func infoView(textHeader: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(textHeader)
                .font(.custom(CustomFonts.regular, size: 15))
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))

            horizontalInfoRow("NEW_SKILL_PRICE".localized, info: skill.price, hasDivider: true)
            horizontalInfoRow("CATEGORY".localized, info: skill.category.name, hasDivider: true)
            if let categoryIsOnline = skill.category.is_manual {
                if categoryIsOnline {
                    horizontalInfoRow("NEW_SKILL_PRESENCIAL".localized, info: "NEW_SKILL_PRESENCIAL".localized, hasDivider: true,icon: .inPersonIcon)
                } else {
                    horizontalInfoRow("NEW_SKILL_PRESENCIAL".localized, info: "NEW_SKILL_ONLINE".localized, icon: .onlineIcon)
                }
            } else {
                if let skillOnLine = skill.is_online {
                    if skillOnLine {
                        horizontalInfoRow("NEW_SKILL_PRESENCIAL".localized, info: "NEW_SKILL_ONLINE".localized, icon: .onlineIcon)
                    } else {
                        horizontalInfoRow("NEW_SKILL_PRESENCIAL".localized, info: "NEW_SKILL_PRESENCIAL".localized, hasDivider: true,icon: .inPersonIcon)
                    }
                }
            }
        }
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
    }
    
    /// Horizontal info row view
    @ViewBuilder
    private func horizontalInfoRow(_ header: String, info: String, hasDivider: Bool = false, icon: ImageResource? = nil) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(header)
                    .font(.custom(CustomFonts.medium, size: 16))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                Spacer()
                if let icon {
                    iconView(icon)
                }
                Text(info)
                    .font(.custom(CustomFonts.regular, size: 16))
                    .foregroundStyle(ColorManager.primaryBasicColor)
            }
            if hasDivider {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.7))
            }
        }
    }
    
    /// Icon View
    @ViewBuilder
    private func iconView(_ image: ImageResource) -> some View {
        Image(image)
            .resizable()
            .renderingMode(.template)
            .frame(width: 25, height: 20)
            .foregroundStyle(ColorManager.primaryBasicColor)
        
    }
    
    /// User Info View
    @ViewBuilder
    private func userInfoView(_ header: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text(header)
                .font(.custom(CustomFonts.regular, size: 15))
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
            HStack {
                Text(skill.user.name)
                    .font(.custom(CustomFonts.medium, size: 16))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                Spacer()
                imageProfile
            }
            Text(skill.user.email)
                .font(.custom(CustomFonts.medium, size: 16))
                .foregroundStyle(ColorManager.primaryGrayColor)
            if skill.user.id != UserDefaults.standard.userSaved?.id {
                Button {
                    Task {
                        try await chatManager.createChat(with: skill.user)
                        coordinator.pop()
                        activeTab = .chat
                    }
                } label: {
                    Text("SKILL_DETAIL_WRITE_MESSAGE".localized)
                        .foregroundStyle(ColorManager.defaultWhite)
                        .font(.custom(CustomFonts.medium, size: 17))
                    
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(ColorManager.primaryBasicColor)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
    }
    
    /// Profile Image
    @ViewBuilder
    private var imageProfile: some View {
        if let userImage = skill.user.profileImageURL, let url = URL(string: userImage) {
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
                .padding(10)
                .background(ColorManager.defaultWhite)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
        }
    }
}

#Preview {
    @Previewable @State  var coordinator = Coordinator<MainCoordinatorPages>()

    SkillDetailView(skill: Skill.sample, activeTab: .constant(.home))
        .environment(coordinator)
}
