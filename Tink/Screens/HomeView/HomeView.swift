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
            CategoryCapsuleView(selectedCategory: $selectedCategory, categories: databaseManager.categories)
        }
        .safeAreaTopPadding(proxy: proxy)
        .onAppear {
            Task {
                await databaseManager.fetchCategories()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorManager.bgColor)
    }
}

// MARK: - SUBVIEWS
extension HomeView {
    

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
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
