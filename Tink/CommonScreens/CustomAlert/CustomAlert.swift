//
//  CustomAlert.swift
//  dogify
//
//  Created by Pablo Fuertes ruiz on 23/1/25.
//

import SwiftUI

struct CustomAlert: View {
    
    // MARK: - PROPERTIES
    let title: String
    let bodyText: String
    let acceptAction: () -> Void
    let cancelAction: (() -> Void)?
    
    // MARK: - BODY
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                ColorManager.primaryGrayColor.opacity(0.4)
                VStack {
                    closeButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    VStack(spacing: 20) {
                        Text(title)
                            .font(.custom(CustomFonts.bold, size: 19))
                            .foregroundStyle(ColorManager.defaultBlack)
                            .lineLimit(1)
                        Text(bodyText)
                            .font(.custom(CustomFonts.regular, size: 17))
                            .foregroundStyle(ColorManager.primaryGrayColor)
                            .multilineTextAlignment(.center)
                        buttonsView
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(ColorManager.defaultWhite)
                    }
                }
                .transition(.blurReplace)
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - SUBVIEWS
extension CustomAlert {
    
    /// Buttons view
    @ViewBuilder
    private var buttonsView: some View {
        HStack(spacing: 10) {
            Button {
                acceptAction()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(ColorManager.primaryBasicColor)
                    Text("ACCEPT".localized)
                        .font(.custom(CustomFonts.regular, size: 18))
                        .foregroundStyle(ColorManager.defaultWhite)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
            if let cancelAction {
                Button {
                    cancelAction()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
                        Text("GOBACK".localized)
                            .font(.custom(CustomFonts.regular, size: 18))
                            .foregroundStyle(ColorManager.defaultWhite)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                }
            }
        }
    }
    
    @ViewBuilder
    private var closeButton: some View {
        if let cancelAction {
            Button {
                cancelAction()
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(ColorManager.defaultWhite)
                    Image(.closeIcon)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
            }
        }
    }
}

#Preview {
    CustomAlert(title: "Cerrar sesión", bodyText: "Estas seguro de que quieres cerrar la sesión", acceptAction: {}, cancelAction: {})
}
