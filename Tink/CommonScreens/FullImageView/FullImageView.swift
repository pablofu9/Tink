//
//  FullImageView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 20/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FullImageView: View {
    
    let image: String?
    let editAction: () -> Void
    let backAction: () -> Void

    // MARK: - NAMESPACE
    let nameSpace: Namespace.ID
    
    
    var body: some View {
        ZStack {
            ColorManager.primaryBasicColor
            if let image ,let url = URL(string: image) {
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
                .matchedGeometryEffect(id: "image", in: nameSpace)
                .transition(.scale(scale: 1))
                .frame(width: UIScreen.main.bounds.size.width - 70, height: UIScreen.main.bounds.size.width - 70)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
            } else {
                Image(.noProfileIcon)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.size.width - 90, height: UIScreen.main.bounds.size.width - 90)
                    .padding(20)
                    .background(ColorManager.defaultWhite)
                    .clipShape(Circle())
                    .matchedGeometryEffect(id: "image", in: nameSpace)
                    .transition(.scale)
                    .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
            }
            Button {
                withAnimation {
                    editAction()
                }
            } label: {
                Text("EDIT".localized)
                    .font(.custom(CustomFonts.medium, size: 20))
                    .foregroundStyle(ColorManager.defaultWhite)
            }
            .padding(40)
            .frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .bottomLeading)
            BackButton {
                withAnimation {
                    backAction()
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    FullImageView(image: "https://res.cloudinary.com/dbzimmpcy/image/upload/v1739975987/user_rRXxJcYuUTgC12krzxz6ZDT7CbO2.jpg", editAction: {}, backAction: {}, nameSpace: Namespace().wrappedValue)
}
