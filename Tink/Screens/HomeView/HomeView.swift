//
//  HomeView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - PROPERTIES
    // Database manager
    @EnvironmentObject var databaseManager: FSDatabaseManager
    // Selected category
    @State var selectedCategory: FSCategory?
    // Geometry proxy from main view
    let proxy: GeometryProxy
    // Searcher text
    @State var searchText: String = ""
    // Authentication manager
    @Environment(AuthenticatorManager.self) private var authenticatorManager

    // MARK: - BODY
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 30) {
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                }
                .safeAreaInset(edge: .bottom) {
                    EmptyView()
                        .frame(height: Measures.kTabBarHeight + 30)
                }
                .safeAreaTopPadding(proxy: proxy)
                .padding(.top, 120)
                .overlay(alignment: .top) {
                    headerView(proxy)
                }
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: "SCROLL")
            .onAppear {
                Task {
                    await databaseManager.fetchCategories()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorManager.bgColor)
    }
}

// MARK: - SUBVIEWS
extension HomeView {
    
    // Collapsable header view
    @ViewBuilder
    private func headerView(_ proxy: GeometryProxy) -> some View {
        let height = proxy.safeAreaInsets.top + 70
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.6))
            let interpolatedOpacity = max(0, min(1, 1 + progress))
            VStack(spacing: 15) {
              
                ColorManager.bgColor
                    .frame(height: max(40, proxy.safeAreaInsets.top + progress * 10))
               
                searcherTextfield
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
              
                let customheight = max(0, 40 + progress * 10)
            
                CategoryCapsuleView(selectedCategory: $selectedCategory, categories: databaseManager.categories)
                    .opacity(interpolatedOpacity)
                    .frame(height: customheight)
            }
            .background(ColorManager.bgColor)
            .offset(y: -minY)
            .frame(height: height, alignment: .top)
        }
        .frame(height: height)
    }
    
    // Searcher textfield
    @ViewBuilder
    private var searcherTextfield: some View {
        TextField("",text: $searchText, prompt: promptSearcher)
            .textFieldStyle(SearcherTextfieldStyle())
    }
    
    // Propmt text for textfield
    @ViewBuilder
    private var promptSearcher: Text {
        Text("SEARCH".localized)
            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.4))
            .font(.custom(CustomFonts.regular, size: 16))
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
        
        
        return GeometryReader { proxy in
            HomeView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
