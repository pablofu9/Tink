//
//  NewSkillView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI

struct NewSkillView: View {
    
    // MARK: - ENUM TO CONTROL FOCUS
    enum NewSkillFocus {
        case name
        case description
        case price
    }
    
    // MARK: - ENUM TO SELECT PRICE
    enum NewSkillPrice: String, CaseIterable, CustomStringConvertible {
        case eurHour = "€/H"
        case eur = "€"
        
        var description: String {
            return self.rawValue
        }
    }
    
    enum NewSkillOnline: String, CaseIterable, CustomStringConvertible {
        case online = "Online"
        case presencial = "Presencial"
        
        var description: String {
            return self.rawValue
        }
    }
    
    // MARK: - VIEW PRESENTED FLAG
    @Binding var isMiddlePressed: Bool
    
    // MARK: - TEXTFIELD VARIABLES
    @State private var skillName: String = ""
    @State private var skillDescription: String = ""
    @State private var price: String = ""
    @State private var selectedPrice: NewSkillPrice? = nil
    @State private var newSkillOnline: NewSkillOnline? = nil
    var counter: Int {
        150 - skillDescription.count
    }
    
    // MARK: - FOCUS STATE CONTROLLER
    @FocusState var focusState: NewSkillFocus?
    
    // MARK: - SELECTED CATEGORY VAR
    @State var selectedCategory: FSCategory?

    // MARK: - DATABASE MANAGER
    @EnvironmentObject var databaseManager: FSDatabaseManager

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        nameView
                        descriptionView
                        priceView
                        categoryPicker
                        onlinePickerView
                        createAnnounce
                            .padding(.top, 40)
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: Measures.kTopShapeHeightSmaller - 10)
                    }
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                }
                .safeAreaTopPadding(proxy: proxy)
                headerView(proxy)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(ColorManager.defaultWhite)
        }
        .onAppear {
            Task {
                await databaseManager.fetchCategories()
            }
        }
    }
}

// MARK: - SUBVIEWS
extension NewSkillView {
    
    /// Header View
    @ViewBuilder
    private func headerView(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            topShape
            HStack(alignment: .top, spacing: 20) {
                backIcon
                VStack(alignment: .leading, spacing: 0) {
                    Text("NEW_SKILL_HEADER".localized)
                        .font(.custom(CustomFonts.bold, size: 27))
                        .foregroundStyle(ColorManager.defaultWhite)
                    Text("NEW_SKILL_WDYD".localized)
                        .font(.custom(CustomFonts.regular, size: 18))
                        .foregroundStyle(ColorManager.defaultWhite)
                }
            }
            .padding(.horizontal, Measures.kHomeHorizontalPadding)
            .safeAreaTopPadding(proxy: proxy)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Top shape view
    @ViewBuilder
    private var topShape: some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: Measures.kTopShapeHeight, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
    }
    
    /// back Button
    @ViewBuilder
    private var backIcon: some View {
        BackButton(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isMiddlePressed = false
            }
        })
    }
    
    /// Hability name view
    @ViewBuilder
    private var nameView: some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text("NEW_SKILL_ANNOUNCE_NAME".localized)
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                .font(.custom(CustomFonts.regular, size: 17))
            TextField("", text: $skillName, prompt: propmtView("NEW_SKILL_ANNOUNCE_PROMPT".localized))
                .textFieldStyle(LoginTextField(focused: focusState == .name))
                .focused($focusState, equals: .name)
                .onSubmit {
                    focusState = .description
                }
                .submitLabel(.continue)
        }
    }
    
    /// Skill description View
    @ViewBuilder
    private var descriptionView: some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text("NEW_SKILL_DESCRIPTION_VIEW".localized)
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                .font(.custom(CustomFonts.regular, size: 17))
            TextEditor(text: $skillDescription)
                .accentColor(ColorManager.primaryGrayColor)
                .modifier(CustomTextEditorModifier(focused: focusState == .description))
                .focused($focusState, equals: .description)
                .limitText($skillDescription, to: 150)
                .onSubmit {
                    focusState = .price
                }
                .submitLabel(.continue)
                .overlay(alignment: .bottomTrailing) {
                    Text("\(counter)/150")
                        .font(.custom(CustomFonts.regular, size: 16))
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.4))
                        .padding(.trailing, 7)
                        .padding(.bottom, 2)
                }
                .overlay(alignment: .topLeading) {
                    if skillDescription.isEmpty {
                        propmtView("NEW_SKILL_DESCRIPTION_PROMPT".localized)
                            .transition(.opacity)
                            .padding(.leading, 13)
                            .padding(.top, 17)
                    }
                }
             
        }
    }
    
    /// Hability name view
    @ViewBuilder
    private var priceView: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading ,spacing: 3) {
                Text("NEW_SKILL_PRICE".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                    .font(.custom(CustomFonts.regular, size: 17))
                TextField("", text: $price, prompt: propmtView("NEW_SKILL_PRICE_PROPMT".localized))
                    .textFieldStyle(LoginTextField(focused: focusState == .price))
                    .focused($focusState, equals: .price)
                    .keyboardType(.numberPad)
                    .onSubmit {
                        focusState = nil
                    }
                    .submitLabel(.done)
            }
            GenericPickerView(
                title: "NEW_SKILL_PRICE_FORMAT".localized,
                options: NewSkillPrice.allCases,
                selectedOption: $selectedPrice
            )
        }
    }
    
    /// Propmt view for everything
    @ViewBuilder
    private func propmtView(_ text: String) -> Text {
        Text(text)
            .font(.custom(CustomFonts.regular, size: 17))
            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.6))
    }
    
    // Category picker
    @ViewBuilder
    private var categoryPicker: some View {
        GenericPickerView(
            title: "NEW_SKILL_SELECT_CATEGORY".localized,
            options: databaseManager.categories,
            selectedOption: $selectedCategory
        )
    }
    
    /// Online or presencial picker view
    @ViewBuilder
    private var onlinePickerView: some View {
        if let selectedCategory, selectedCategory.is_manual == nil {
            VStack(alignment: .leading ,spacing: 3) {
                Text("NEW_SKILL_WHERE_OFFER".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                    .font(.custom(CustomFonts.regular, size: 17))
                HStack(spacing: 0) {
                    ForEach(NewSkillOnline.allCases, id: \.self) { skill in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                newSkillOnline = skill
                            }
                        }) {
                            Text(skill.description)
                                .foregroundStyle(newSkillOnline == skill ? ColorManager.defaultWhite : ColorManager.primaryGrayColor)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(newSkillOnline == skill ? ColorManager.primaryBasicColor.opacity(0.7) : .clear)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(height: 35)
                .background(Color.clear)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ColorManager.primaryGrayColor, lineWidth: 1)
                }
            }
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var createAnnounce: some View {
        Button {
            Task {
//                if let selectedCommunity, let provinceSelected, let selectedTown {
//                    try await databaseManager.createNewUser(name: name, surname: surname, community: selectedCommunity.label, province: provinceSelected.label, locality: selectedTown.label)
//                }
            }
        } label: {
            Text("NEW_SKILL_CREATE_ANNOUNCE".localized)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .font(.custom(CustomFonts.bold, size: 20))
                .foregroundStyle(ColorManager.defaultWhite)
                .background(isFormValid() ? ColorManager.primaryBasicColor : ColorManager.primaryBasicColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!isFormValid())
    }
}

// MARK: - PRIVATE FUNCS
extension NewSkillView {
    
    // Check if form is valid
    func isFormValid() -> Bool {
        let isValid = selectedPrice != nil &&
        selectedCategory != nil &&
        !skillName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !skillDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return isValid
    }
}


struct NewSkillView_Previews: PreviewProvider {
    static var previews: some View {
        @Previewable @State var isMiddlePressed: Bool = false
        let mockManager = FSDatabaseManager()
        mockManager.categories = [
            FSCategory(id: "1", name: "Albañilería", is_manual: true),
            FSCategory(id: "2", name: "Carpintería", is_manual: true),
            FSCategory(id: "3", name: "Clases online", is_manual: false),
        ]
        
        return NewSkillView(isMiddlePressed: $isMiddlePressed)
                .environmentObject(mockManager)
                .ignoresSafeArea()

    }
}
