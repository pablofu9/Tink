//
//  CategoryCapsuleView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI

struct CategoryCapsuleView: View {
    
    @Binding var selectedCategory: FSCategory?
    var categories: [FSCategory]
    
    // MARK: - BODY
     var body: some View {
         
         let sortedCategories = categories.sorted {
               if $0.name == "todas" { return true }
               if $1.name == "todas" { return false }
               return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
           }
         
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
         .onChange(of: categories) {
             if !categories.isEmpty {
                 if let todasCategory = categories.first(where: { $0.name == "todas" }) {
                     selectedCategory = todasCategory
                 }
             }
         }
     }
    
    // Categori capsule
    @ViewBuilder
    private func categoryCapsule(_ category: FSCategory) -> some View {
        Button {
            withAnimation(.easeIn(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(category.name)
                .font(.custom(CustomFonts.regular, size: 18))
                .foregroundStyle(selectedCategory == category ? ColorManager.defaultWhite : ColorManager.primaryGrayColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 2)
                .background {
                    if selectedCategory == category {
                        Capsule()
                            .fill(ColorManager.primaryBasicColor)
                            .transition(.blurReplace)
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
    @Previewable @State var selectedCategory: FSCategory?
    let categories: [FSCategory] = [ FSCategory(id: "1", name: "Albañilería", is_manual: true),
                                     FSCategory(id: "2", name: "Carpintería", is_manual: true),
                                     FSCategory(id: "3", name: "Clases online", is_manual: false)]
    CategoryCapsuleView(selectedCategory: $selectedCategory, categories: categories)
}
