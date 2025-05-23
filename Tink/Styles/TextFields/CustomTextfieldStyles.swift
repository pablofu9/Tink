//
//  CustomTextfieldStyles.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 7/2/25.
//

import Foundation
import SwiftUI

struct SearcherTextfieldStyle: TextFieldStyle {
    
    var focused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(CustomFonts.regular, size: 16))
            .foregroundStyle(ColorManager.primaryGrayColor)
            .accentColor(ColorManager.primaryGrayColor)
            .padding(.leading, 45)
            .padding(.trailing, 40)
            .padding(.vertical, 8)
            .background(ColorManager.defaultWhite)
            .autocorrectionDisabled()
            .clipShape(Capsule())
            .minimumScaleFactor(0.9)
            .background {
                Capsule()
                    .stroke(lineWidth: focused ? 2 : 1)
                    .foregroundStyle(focused ? ColorManager.primaryBasicColor : ColorManager.primaryGrayColor.opacity(0.7))
                    .animation(.easeInOut(duration: 0.3), value: focused)
            }
            .overlay(alignment: .leading) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
                    .padding(.leading, 15)
            }
    }
}

struct LoginTextField: TextFieldStyle {
    
    var focused: Bool
   
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(CustomFonts.regular, size: 17))
            .foregroundStyle(ColorManager.primaryGrayColor)
            .accentColor(ColorManager.primaryGrayColor)
            .padding(.leading, 15)
            .padding(.trailing, 40)
            .padding(.vertical, 8)
            .background(ColorManager.defaultWhite)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .minimumScaleFactor(0.9)
            .overlay {
                if !focused {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
            }
            .background {
                if focused {
                    RoundedRectangle(cornerRadius: 10)
                        .offset(x: 4, y: 4)
                        .foregroundStyle(ColorManager.primaryBasicColor)
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.3), value: focused)
                }
            }
            .overlay {
                if focused {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(ColorManager.primaryBasicColor)
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.3), value: focused)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: focused)

    }
}


#Preview {
    @Previewable @State var text: String = ""
    @Previewable @State var prompt: String = ""
    ZStack {
        ColorManager.bgColor
        TextField("", text: $text)
            .textFieldStyle(SearcherTextfieldStyle(focused: false))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray)
}


