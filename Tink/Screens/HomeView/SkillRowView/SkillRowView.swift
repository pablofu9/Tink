//
//  SkillRowView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 17/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SkillRowView: View {
    
    // MARK: - SKILL
    let skill: Skill
    
    // MARK: - IMAGE HEIGHT COMPUTED PROPERTY
    var imageHeight: CGFloat = 160
    var totalHeight: CGFloat = 250
    // Database manager
    @EnvironmentObject var databaseManager: FSDatabaseManager

    // MARK: - BODY
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack(alignment: .leading,spacing: 1) {
                    imageView(proxy)
                    
                    HStack {
                        Text(skill.price)
                            .font(.custom(CustomFonts.regular, size: 16))
                            .foregroundStyle(ColorManager.primaryGrayColor)
                        Spacer()
                    }
                    Text(skill.user.name)
                        .font(.custom(CustomFonts.regular, size: 16))
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.6))
                    if let categoryIsOnline = skill.category.is_manual {
                        if categoryIsOnline {
                            inPersonView
                        } else {
                            onlineView
                        }
                    } else {
                        if let skillOnLine = skill.is_online {
                            if skillOnLine {
                                onlineView
                            } else {
                                inPersonView
                            }
                        }
                    }
                }
            }
            .frame(height: proxy.size.height, alignment: .top)
        }
        .frame(width: (UIScreen.main.bounds.size.width - 48) / 2)
        .frame(height: totalHeight, alignment: .top)
    }
}

// MARK: - SUBVIEWS
extension SkillRowView {
    
    /// Capsule view
    @ViewBuilder
    private func capsuleView(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(ColorManager.defaultWhite)
            .font(.custom(CustomFonts.regular, size: 15))
            .padding(.horizontal, 10)
            .padding(.vertical, 1)
            .background(ColorManager.primaryBasicColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(ColorManager.defaultWhite)
            }
    }
    
    /// Image view
    @ViewBuilder
    private func imageView(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            if let imageUrl = skill.category.image_url, let url = URL(string: imageUrl) {
                WebImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                    case .failure:
                        LoadingView()
                    @unknown default:
                        LoadingView()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: (UIScreen.main.bounds.size.width - 48) / 2, height: imageHeight)
                .cornerRadius(10)
            } else {
                ColorManager.primaryGrayColor.opacity(0.5)
                    .frame(height: imageHeight)
                    .cornerRadius(10)
            }
            VStack(alignment: .leading) {
                nameView
                Spacer()
                capsuleView(skill.category.name)
            }
            .padding(6)
            .frame(width: proxy.size.width, height: proxy.size.height / 2.8, alignment: .topLeading)
            .background(ColorManager.secondaryGrayColor.opacity(0.8))
            .cornerRadius(10)
        }
    }
    
    /// Name and user view
    @ViewBuilder
    private var nameView: some View {
        HStack {
            Text(skill.name)
                .font(.custom(CustomFonts.bold, size: 14))
                .foregroundStyle(ColorManager.primaryGrayColor)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    private func iconView(_ image: ImageResource) -> some View {
        Image(image)
            .resizable()
            .renderingMode(.template)
            .frame(width: 25, height: 20)
            .foregroundStyle(ColorManager.primaryBasicColor)
        
    }
    
    /// Text if its online or not
    @ViewBuilder
    private func isOnlineText(_ text: String) -> Text {
        Text(text)
            .foregroundStyle(ColorManager.primaryBasicColor)
            .font(.custom(CustomFonts.medium, size: 17))
            
    }
    
    /// Online view
    @ViewBuilder
    private var onlineView: some View {
        HStack(spacing: 5) {
            iconView(.onlineIcon)
            isOnlineText("NEW_SKILL_ONLINE".localized)
        }
    }
    
    /// In person view
    @ViewBuilder
    private var inPersonView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                iconView(.inPersonIcon)
                isOnlineText("NEW_SKILL_PRESENCIAL".localized)
            }
        }
    }
}

#Preview {
    let mockManager = FSDatabaseManager()
    SkillRowView(skill: Skill.sampleArray[1])
        .environmentObject(mockManager)
}
