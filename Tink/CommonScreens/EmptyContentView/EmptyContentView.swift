//
//  EmptyContentView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import SwiftUI

struct EmptyContentView: View {
    
    let title: String
    let image: ImageResource
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .foregroundStyle(ColorManager.primaryGrayColor)
                .font(.custom(CustomFonts.regular, size: 22))
            Image(image)
                .resizable()
                .frame(width: 300, height: 300)
        }
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
    }
}

#Preview {
    EmptyContentView(title: "¡Ups! Aún no hay habilidades por aquí. 🚀 ¡Vuelve pronto o sé el primero en publicar la tuya! 💡", image: .emptyIcon)
}
