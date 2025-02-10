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
    
    init(horizontalPadding: CGFloat = Measures.kHomeHorizontalPadding, text: String, action: @escaping () -> Void) {
        self.horizontalPadding = horizontalPadding
        self.text = text
        self.action = action
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
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.horizontal, horizontalPadding)
        }
    }
}

#Preview {
    DefaultButton(text: "Login") {
        print("Login tapped!")
    }
}
