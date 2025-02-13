//
//  SkillCardView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SkillCardView: View {
    
    var skill: Skill
    @State var isAnimating: Bool = true

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                imageView
                VStack(alignment: .leading ,spacing: 2) {
                    HStack {
                        Text(skill.name)
                            .font(.custom(CustomFonts.semiBold, size: 19))
                            .foregroundStyle(ColorManager.defaultWhite)
                        Spacer()
                        Text(skill.user.name)
                            .font(.custom(CustomFonts.light, size: 17))
                            .foregroundStyle(ColorManager.defaultWhite)
                    }
                    Text(skill.description)
                        .font(.custom(CustomFonts.regular, size: 15))
                        .foregroundStyle(ColorManager.defaultWhite)
                        .lineLimit(3)
                    Spacer()
                    HStack(spacing: 7) {
                        capsuleView(skill.price)
                        capsuleView(skill.category.name)
                        if let categoryOnline = skill.category.is_manual {
                            capsuleView(!categoryOnline ? "NEW_SKILL_ONLINE".localized : "NEW_SKILL_PRESENCIAL".localized)
                        } else  if let is_online = skill.is_online {
                            capsuleView(is_online ? "NEW_SKILL_ONLINE".localized : "NEW_SKILL_PRESENCIAL".localized)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: proxy.size.height / 2, alignment: .top)
                .background(ColorManager.primaryGrayColor.opacity(0.7))
                .cornerRadius(10)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 26, height: 250)
    }
    
}

// MARK: - SUBVIEWS
extension SkillCardView {
    
    @ViewBuilder
    private var imageView: some View {
        if let imageUrl = skill.category.image_url {
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 26, height: 250)
                .cornerRadius(10)
        } else {
            ColorManager.defaultWhite
                .frame(width:  UIScreen.main.bounds.width - 26, height: 250)
        }
    }
    
    @ViewBuilder
    private func capsuleView(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(ColorManager.defaultWhite)
            .font(.custom(CustomFonts.regular, size: 16))
            .padding(.horizontal, 10)
            .padding(.vertical, 1)
            .background(ColorManager.primaryBasicColor)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(ColorManager.defaultWhite)
            }
    }
}

#Preview {
    SkillCardView(skill: Skill.sample)
}
