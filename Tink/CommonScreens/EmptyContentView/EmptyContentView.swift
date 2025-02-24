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
    var frame: Double = 300.0
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .foregroundStyle(ColorManager.primaryGrayColor)
                .font(.custom(CustomFonts.regular, size: 22))
            Image(image)
                .resizable()
                .frame(width: frame, height: frame)
        }
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
    }
}

#Preview {
    EmptyContentView(title: "¡Ups! Aún no hay habilidades por aquí. 🚀 ¡Vuelve pronto o sé el primero en publicar la tuya! 💡", image: .emptyIcon)
}
