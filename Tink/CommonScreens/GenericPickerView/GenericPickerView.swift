//
//  GenericPickerView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import Foundation
import SwiftUI

struct GenericPickerView<T: Hashable & CustomStringConvertible>: View {
    var title: String
    var options: [T]
    @Binding var selectedOption: T?
    
    var body: some View {
        if !options.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                    .font(.custom(CustomFonts.regular, size: 17))
                
                Picker("", selection: $selectedOption) {
                    Text(title)
                        .tag(nil as T?)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                    
                    ForEach(options, id: \.self) { option in
                        Text(option.description)
                            .font(.custom(CustomFonts.bold, size: 12))
                            .foregroundStyle(ColorManager.primaryGrayColor)
                            .tag(option)
                    }
                }
                .labelsHidden()
                .accentColor(ColorManager.primaryGrayColor)
                .pickerStyle(MenuPickerStyle())
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
            }
            .transition(.opacity)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
