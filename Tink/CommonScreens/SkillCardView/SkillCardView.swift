//
//  SkillCardView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SkillCardView: View {
    
    @Binding var skill: Skill
    
    // MARK: - BODY
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                imageView
                offsetCapsule
                VStack(alignment: .leading ,spacing: 2) {
                    HStack {
                        Text(skill.name)
                            .font(.custom(CustomFonts.semiBold, size: 19))
                            .foregroundStyle(ColorManager.defaultWhite)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text(UserDefaults.standard.userSaved?.name ?? "User")
                            .font(.custom(CustomFonts.light, size: 17))
                            .foregroundStyle(ColorManager.defaultWhite)
                    }
                    Text(skill.description)
                        .font(.custom(CustomFonts.regular, size: 15))
                        .foregroundStyle(ColorManager.defaultWhite)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack(spacing: 7) {
                            capsuleView(skill.price)
                            if let categoryOnline = skill.category.is_manual {
                                capsuleView(!categoryOnline ? "NEW_SKILL_ONLINE".localized : "NEW_SKILL_PRESENCIAL".localized)
                            } else  if let is_online = skill.is_online {
                                capsuleView(is_online ? "NEW_SKILL_ONLINE".localized : "NEW_SKILL_PRESENCIAL".localized)
                            }
                            
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: proxy.size.height / 1.7, alignment: .top)
                .background(ColorManager.primaryGrayColor.opacity(0.8))
                .cornerRadius(10)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 26, height: 280)
    }
    
}

// MARK: - SUBVIEWS
extension SkillCardView {
    
    /// Top capsule view
    @ViewBuilder
    private var offsetCapsule: some View {
        VStack(alignment: .trailing) {
            capsuleView(skill.category.name)
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.3), radius: 2, y: -2)
            Spacer()
        }
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .offset(y: -10)
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let imageUrl = skill.category.image_url, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 26, height: 280)
                        .cornerRadius(10)
                case .failure:
                    Color.gray.frame(width: UIScreen.main.bounds.width - 26, height: 280)
                @unknown default:
                    Color.gray.frame(width: UIScreen.main.bounds.width - 26, height: 280)
                }
            }
        } else {
            Color.gray.frame(width: UIScreen.main.bounds.width - 26, height: 280)
        }
    }
    
    /// Capsule view
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
    @Previewable @State var skill: Skill = Skill.sample
    SkillCardView(skill: $skill)
}
