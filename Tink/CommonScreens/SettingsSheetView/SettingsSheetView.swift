//
//  SettingsSheetView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 20/2/25.
//

import SwiftUI

struct SettingsSheetView: View {
    
    let header: String
    let bodyText: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            BackButton(action: {
                dismiss()
            })
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Text(header)
                        .font(.custom(CustomFonts.bold, size: 22))
                        .foregroundStyle(ColorManager.defaultBlack)
                    Text(bodyText)
                        .font(.custom(CustomFonts.regular, size: 18))
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(ColorManager.bgColor)
  
    }
}

#Preview {
    SettingsSheetView(header: "Sobre nosotros", bodyText: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
}
