//
//  HomeFilterPicker.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 27/2/25.
//

import SwiftUI

struct HomeFilterPicker<T: Identifiable & Hashable>: View {
    var title: String
    var items: [T]
    @Binding var selectedItem: T?
    var displayName: (T) -> String // Closure para obtener el nombre del objeto
    
    var body: some View {
        Menu {
            Picker("", selection: $selectedItem) {
                Text(title)
                    .tag(nil as T?)
                    .font(.custom(CustomFonts.regular, size: 17))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                ForEach(items) { item in
                    Text(displayName(item))
                        .tag(item as T?)
                        .font(.custom(CustomFonts.regular, size: 17))
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
            }
            .labelsHidden()
        } label: {
            Text(selectedItem.map(displayName) ?? title)
                .font(.custom(CustomFonts.regular, size: 17))
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(
                    Capsule()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                        .frame(width: UIScreen.main.bounds.size.width / 2.3)
                )
                .overlay {
                    if let _ = selectedItem {
                        Capsule()
                            .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.3))
                            .frame(width: UIScreen.main.bounds.size.width / 2.3)
                    }
                }
        }
        .frame(width: UIScreen.main.bounds.size.width / 2.3, height: 35)
    }
}
