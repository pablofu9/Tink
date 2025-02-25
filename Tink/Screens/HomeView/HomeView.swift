//
//  HomeView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI

struct HomeView: View {
    
    // Filter deploey controller
    enum FilterDeploy: CaseIterable {
        case categories
        case online
        
        var description: String {
            switch self {
            case .categories:
                return "CATEGORIES".localized
            case .online:
                return "PRESENTIALITTY".localized
            }
        }
    }
    
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
    // Filter deploye controller
    @State private var filterDeploy: FilterDeploy?
    let columns = [
           GridItem(.flexible(), spacing: 10),
           GridItem(.flexible(), spacing: 10) 
       ]
    // Selected skill for navigation
    @State private var selectedSkill: Skill?
    // Active tab
    @Binding var activeTab: TabModel
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                if !databaseManager.allSkillsSaved.isEmpty {
                    LazyVGrid(columns: columns, spacing: 50) {
                        allSkillsView
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(16)
                    .safeAreaInset(edge: .bottom) {
                        EmptyView()
                            .frame(height: Measures.kTabBarHeight + 70)
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                        .frame(height: Measures.kTopShapeHeightSmaller + (filterDeploy == nil ? (UIScreen.main.bounds.size.height < 700 ? 20 : -30) : (UIScreen.main.bounds.size.height < 700 ? 50 : 0)))
                    }
                    .safeAreaTopPadding(proxy: proxy)
                    .overlay(alignment: .top) {
                        headerView(proxy)
                    }
                   
                } else {
                    LazyVStack {
                        EmptyContentView(title: "EMPTY_SKILLS".localized, image: .emptyIcon)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(16)
                    .safeAreaInset(edge: .bottom) {
                        EmptyView()
                            .frame(height: Measures.kTabBarHeight + 70)
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: Measures.kTopShapeHeightSmaller + 60)
                    }
                    .safeAreaTopPadding(proxy: proxy)
                    .overlay(alignment: .top) {
                        headerView(proxy)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: "SCROLL")
            .onAppear {
                Task {
                    try await databaseManager.syncSkills()
                    await databaseManager.fetchCategories()
                }
            }
           
        }
        .fullScreenCover(item: $selectedSkill) { skill in
            SkillDetailView(skill: skill, activeTab: $activeTab)
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
            let invertedOpacity = (1 - interpolatedOpacity) / 2
            VStack(spacing: 15) {
              
                Color.clear
                    .frame(height: max(35, proxy.safeAreaInsets.top + progress * 20))
                
                searcherTextfield
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .shadow(color: ColorManager.primaryGrayColor.opacity(invertedOpacity), radius: 2, x: 0, y: 2)
                VStack(alignment: .leading ,spacing: 10) {
                   
                    VStack(alignment: .leading, spacing: 3) {
                        filterHeader(.categories, content: {
                            CategoryCapsuleView(selectedCategories: $selectedCategories, categories: databaseManager.categories)
                        })
                    }
                    homeOnlineHeader
                    if minY > 120 {
                        ProgressView()
                            .tint(ColorManager.primaryBasicColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onAppear {
                                Task {
                                    databaseManager.loading = true
                                    try await Task.sleep(nanoseconds: 1_000_000_000)
                                    try await databaseManager.syncSkills()
                                    await databaseManager.fetchCategories()
                                }
                            }
                    }
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
        filterHeader(.online, content: {
            OnlineFilterView(onlineState: $onlineState)
        })
    }
    
    /// Skills view based on filters
    @ViewBuilder
    private var allSkillsView: some View {
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
                Button {
                    selectedSkill = skill
                } label: {
                    SkillRowView(skill: skill)
                }
            }
        }
    }
    
    @ViewBuilder
    private func categoryHeader(_ deploy: FilterDeploy) -> some View {
        Text(deploy.description)
            .foregroundStyle(ColorManager.primaryGrayColor)
            .font(.custom(CustomFonts.medium, size: 17))
    }
    
    @ViewBuilder
    private func filterHeader<Content: View>(_ deploy: FilterDeploy, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    categoryHeader(deploy)
                    Spacer()
                    Image(systemName: filterDeploy == deploy ? "chevron.up" : "chevron.down")
                }
            }
            .padding(.horizontal, Measures.kHomeHorizontalPadding + 3)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if filterDeploy == deploy {
                        filterDeploy = nil
                    } else {
                        filterDeploy = deploy
                    }
                }
            }
            if filterDeploy == deploy {
                content()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Divider()
                .padding(.horizontal, Measures.kHomeHorizontalPadding + 3)
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
        
        mockManager.allSkillsSaved = []
        return GeometryReader { proxy in
            HomeView(proxy: proxy, activeTab: .constant(.home))
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
