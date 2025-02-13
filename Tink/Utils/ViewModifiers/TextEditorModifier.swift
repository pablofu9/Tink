//
//  TextEditorModifier.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import Foundation
import SwiftUI


struct CustomTextEditorModifier: ViewModifier {
    var focused: Bool

    func body(content: Content) -> some View {
        content
            .frame(minHeight: UIScreen.main.bounds.size.height / 8,  maxHeight: UIScreen.main.bounds.size.height / 4)
            .font(.custom(CustomFonts.regular, size: 17))
            .foregroundStyle(ColorManager.primaryGrayColor)
            .padding(10)
            .background(ColorManager.defaultWhite)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(focused ? ColorManager.primaryBasicColor : ColorManager.primaryGrayColor, lineWidth: focused ? 2 : 1)
            )
            .animation(.easeInOut(duration: 0.3), value: focused)
    }
}
