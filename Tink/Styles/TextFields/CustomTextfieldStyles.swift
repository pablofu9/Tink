//
//  CustomTextfieldStyles.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 7/2/25.
//

import Foundation
import SwiftUI

struct SearcherTextfieldStyle: TextFieldStyle {
    
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(CustomFonts.regular, size: 16))
            .foregroundStyle(ColorManager.primaryGrayColor)
            .accentColor(ColorManager.primaryGrayColor)
            .padding(.leading, 15)
            .padding(.trailing, 40)
            .padding(.vertical, 8)
            .background(ColorManager.defaultWhite)
            .autocorrectionDisabled()
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .shadow(color: ColorManager.defaultBlack.opacity(0.25), radius: 4, x: 0, y: 4)
            .minimumScaleFactor(0.9)
            .overlay(alignment: .trailing) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .padding(.trailing, 15)
            }
    }
}

struct LoginTextField: TextFieldStyle {
    
    var focused: Bool
   
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(CustomFonts.regular, size: 16))
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
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeIn(duration: 0.3), value: focused)
                }
            }
            .overlay {
                if focused {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(ColorManager.primaryBasicColor)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeIn(duration: 0.3), value: focused)
                }
            }
    }
}


#Preview {
    @Previewable @State var text: String = ""
    @Previewable @State var prompt: String = ""
    ZStack {
        TextField("", text: $text)
            .textFieldStyle(LoginTextField(focused: true))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray)
}
