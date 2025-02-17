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
    @State var selectedCategories: [FSCategory] = []
    // Geometry proxy from main view
    let proxy: GeometryProxy
    // Searcher text
    @State var searchText: String = ""
    // Authentication manager
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    // Searcher focused
    @FocusState private var focus: Bool
    // FocusState animation
    @State private var focusAnimation: Bool = false
    // Online Filter
    @State private var onlineState: HomeOnlineState = .all
    // MARK: - BODY
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 30) {
                    allSkillsView
                }
                .safeAreaInset(edge: .bottom) {
                    EmptyView()
                        .frame(height: Measures.kTabBarHeight + 60)
                }
                .safeAreaInset(edge: .top) {
                    EmptyView()
                        .frame(height: Measures.kTopShapeHeightSmaller )
                }
                .safeAreaTopPadding(proxy: proxy)
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
        let height = proxy.safeAreaInsets.top + 120
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.6))
            let interpolatedOpacity = max(0, min(1, 1 + progress))
            VStack(spacing: 15) {
              
                Color.clear
                    .frame(height: max(40, proxy.safeAreaInsets.top + progress * 10))
               
                searcherTextfield
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
              
                VStack(alignment: .leading ,spacing: 10) {
                    CategoryCapsuleView(selectedCategories: $selectedCategories, categories: databaseManager.categories)
                    homeOnlineHeader
                }
                .opacity(interpolatedOpacity)
            }
            .background(Color.clear)
            .offset(y: -minY)
            .frame(height: height, alignment: .top)
        }
        .frame(height: height)
    }
    
    // Searcher textfield
    @ViewBuilder
    private var searcherTextfield: some View {
        HStack(spacing: 5) {
            TextField("",text: $searchText, prompt: promptSearcher)
                .textFieldStyle(SearcherTextfieldStyle())
                .focused($focus)
                .animation(.bouncy(duration: 0.5), value: focusAnimation)

            if focusAnimation {
                Button {
                    withAnimation(.bouncy) {
                        focus = false
                        searchText = ""
                    }
                } label: {
                    Text("CANCEL".localized)
                        .font(.custom(CustomFonts.medium, size: 17))
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onChange(of: focus) {
            withAnimation(.bouncy(duration: 0.5)) {
                focusAnimation = focus
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Propmt text for textfield
    @ViewBuilder
    private var promptSearcher: Text {
        Text("SEARCH".localized)
            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.4))
            .font(.custom(CustomFonts.regular, size: 16))
    }
    
    @ViewBuilder
    private var homeOnlineHeader: some View {
        OnlineFilterView(onlineState: $onlineState)
    }
    
    /// Skills view based on filters
    @ViewBuilder
    private var allSkillsView: some View {
        LazyVStack(spacing: 30) {
            if !databaseManager.allSkillsSaved.isEmpty {
                let filteredSkills = databaseManager.allSkillsSaved
                    .filter { skill in // 3. Filter based on categories
                        selectedCategories.isEmpty || selectedCategories.contains(skill.category)
                    }
                    .filter { skill in
                        // 2. Filter based in onLine / inPerson
                        switch onlineState {
                        case .online:
                            return skill.category.is_manual == false || skill.is_online == true
                        case .inPerson:
                            return skill.category.is_manual == true || skill.is_online == false
                        case .all:
                            return true
                        }
                    }
                    .filter { skill in // 3. Textfield filter
                        searchText.isEmpty || // 3.1. If no text
                        skill.name.lowercased().contains(searchText.lowercased()) || // 3.2. Search by name
                        skill.description.lowercased().contains(searchText.lowercased()) // 3.3. Search by description
                    }
                
                ForEach(filteredSkills) { skill in
                    SkillCardView(skill: skill)
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
        
        mockManager.allSkillsSaved = Skill.sampleArray
        return GeometryReader { proxy in
            HomeView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
