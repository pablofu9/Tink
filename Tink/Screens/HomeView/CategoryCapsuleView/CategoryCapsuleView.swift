//
//  CategoryCapsuleView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI

struct CategoryCapsuleView: View {
    
    // MARK: - SELECTED CATEGORIES
    @Binding var selectedCategories: [FSCategory]
    
    // MARK: - ALL CATEGORIES
    var categories: [FSCategory]
    
    // MARK: - BODY
    var body: some View {
        
        //  Sorted categories
        let sortedCategories = categories.sorted {
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        
        // Scroll view for categories
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(sortedCategories) { category in
                    categoryCapsule(category)
                }
            }
            .safeAreaInset(edge: .leading) {
                Color.clear
                    .frame(width: Measures.kHomeHorizontalPadding, height: 0)
            }
            .safeAreaInset(edge: .trailing) {
                Color.clear
                    .frame(width: Measures.kHomeHorizontalPadding, height: 0)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // Category capsule
    @ViewBuilder
    private func categoryCapsule(_ category: FSCategory) -> some View {
        Button {
            withAnimation(.easeIn(duration: 0.2)) {
                if let index = selectedCategories.firstIndex(where: { $0.id == category.id }) {
                    // Si ya está seleccionada, la quitamos
                    selectedCategories.remove(at: index)
                } else {
                    // Si no está seleccionada, la añadimos
                    selectedCategories.append(category)
                }
            }
        } label: {
            Text(category.name)
                .font(.custom(CustomFonts.regular, size: 18))
                .foregroundStyle(selectedCategories.contains(where: { $0.id == category.id }) ? ColorManager.defaultWhite : ColorManager.primaryGrayColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 2)
                .background {
                    if selectedCategories.contains(where: { $0.id == category.id }) {
                        Capsule()
                            .fill(ColorManager.primaryBasicColor)
                            .transition(.opacity)
                    }
                    Capsule()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.5))
                }
                .padding(.vertical, 3)
        }
    }
}

#Preview {
    @Previewable @State var selectedCategories: [FSCategory] = []
    let categories: [FSCategory] = [ FSCategory(id: "1", name: "Albañilería", is_manual: true),
                                     FSCategory(id: "2", name: "Carpintería", is_manual: true),
                                     FSCategory(id: "3", name: "Clases online", is_manual: false)]
    CategoryCapsuleView(selectedCategories: $selectedCategories, categories: categories)
}
