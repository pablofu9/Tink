//
//  DefaultButton.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import SwiftUI

struct DefaultButton: View {
    
    let text: String
    let horizontalPadding: CGFloat
    let action: () -> Void
    var radius: CGFloat = 25
    
    init(horizontalPadding: CGFloat = Measures.kHomeHorizontalPadding, text: String, action: @escaping () -> Void, radius: CGFloat = 25) {
        self.horizontalPadding = horizontalPadding
        self.text = text
        self.action = action
        self.radius = radius
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .foregroundStyle(ColorManager.defaultWhite)
                .font(.custom(CustomFonts.bold, size: 25))
                .background(ColorManager.primaryBasicColor)
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .padding(.horizontal, horizontalPadding)
        }
    }
}

#Preview {
    DefaultButton(text: "Login") {
        print("Login tapped!")
    }
}
