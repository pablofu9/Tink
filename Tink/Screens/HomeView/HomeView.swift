//
//  HomeView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var databaseManager: FSDatabaseManager
    @State var selectedCategory: FSCategory?
    let proxy: GeometryProxy
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(databaseManager.categories) { category in
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
            .safeAreaTopPadding(proxy: proxy)
            .scrollIndicators(.hidden)
        }
        .onAppear {
            Task {
                await databaseManager.fetchCategories()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorManager.bgColor)
    }
}


extension HomeView {
    
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
                    } else {
                        Capsule()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.5))
                    }
                }
        }
    }
}
struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = FSDatabaseManager()
        mockManager.categories = [
            FSCategory(id: "1", name: "Albañilería", is_manual: true),
            FSCategory(id: "2", name: "Carpintería", is_manual: true),
            FSCategory(id: "3", name: "Clases online", is_manual: false),
        ]
        
        // Usamos GeometryReader para acceder al GeometryProxy
        return GeometryReader { proxy in
            HomeView(proxy: proxy) // Aquí se pasa el proxy correctamente
                .environmentObject(mockManager)
        }
        .previewLayout(.sizeThatFits) // Opcional, solo para ajustar el layout en el preview
    }
}
