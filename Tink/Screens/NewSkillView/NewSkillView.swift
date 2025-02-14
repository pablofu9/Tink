//
//  NewSkillView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI

// MARK: - ENUM TO SELECT PRICE
enum NewSkillPrice: String, CaseIterable, CustomStringConvertible {
    case eurHour = "€/H"
    case eur = "€"
    
    var description: String {
        return self.rawValue
    }
}

struct NewSkillView: View {
    
    // MARK: - ENUM TO CONTROL FOCUS
    enum NewSkillFocus {
        case name
        case description
        case price
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

    // MARK: - EDIT MODE VIEW
    var skill: Skill?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - DELETE BUTTON
    @State private var showAlertDeleteButton: Bool = false

    // MARK: - BODY
    var body: some View {
        content
            .overlay {
                if showAlertDeleteButton {
                    CustomAlert(
                        title: "ALERT_DELETE_HEADER".localized,
                        bodyText: "ALERT_DELETE_BODY".localized,
                        acceptAction: {
                            if let skill {
                                Task {
                                    defer { showAlertDeleteButton = false }
                                    defer { dismiss() }
                                    try await databaseManager.deleteSkill(skill: skill)
                                }
                            }
                        },
                        cancelAction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlertDeleteButton = false
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
    }
}

// MARK: - SUBVIEWS
extension NewSkillView {
    
    /// Content
    @ViewBuilder
    private var content: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        nameView
                        descriptionView
                        priceView
                        categoryPicker
                        onlinePickerView
                        if skill != nil {
                            HStack(spacing: 5) {
                                createAnnounce
                                deleteButton
                            }
                            .padding(.top, 30)
                        } else {
                            createAnnounce
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: Measures.kTopShapeHeightSmaller)
                    }
                    .safeAreaInset(edge: .bottom) {
                        EmptyView()
                            .frame(height: Measures.kTabBarHeight + 70)
                    }
                    .safeAreaTopPadding(proxy: proxy)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .overlay(alignment: .top) {
                        headerView(proxy)
                    }
                }
                .coordinateSpace(name: "SCROLL")
               
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(ColorManager.defaultWhite)
        }
        .onAppear {
            Task {
                await databaseManager.fetchCategories()
                initialyseModifyView()
            }
        }
        .onTapGesture {
            focusState = nil
        }
    }
    
    /// Header View
    @ViewBuilder
    private func headerView(_ proxy: GeometryProxy) -> some View {
        let height = skill == nil ?  Measures.kTopShapeHeight : Measures.kTopShapeHeightSmaller
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.6))
            let dynamicHeight = height + (minY > 0 ? minY : minY)
            let clampedHeight = max(dynamicHeight, 0)
            let interpolatedOpacity = max(0, min(1, 1 + progress))
            ZStack(alignment: .leading) {
                if skill != nil {
                    topShape(clampedHeight)
                    HStack(alignment: .top, spacing: 20) {
                        backIcon
                        VStack(alignment: .leading, spacing: 0) {
                            Text("MODIFY_SKILL_HEADER".localized)
                                .font(.custom(CustomFonts.bold, size: 27))
                                .foregroundStyle(ColorManager.defaultWhite)
                        }
                    }
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .safeAreaTopPadding(proxy: proxy)
                    .padding(.bottom, 50)
                } else {
                    topShape(clampedHeight)
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
            }
            .offset(y: -minY)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: clampedHeight)
            .opacity(interpolatedOpacity)
        }
        .frame(height: height)
    }
    
    /// Top shape view
    @ViewBuilder
    private func topShape(_ height: CGFloat) -> some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: height, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
    }
    
    /// back Button
    @ViewBuilder
    private var backIcon: some View {
        BackButton(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                if skill != nil {
                    dismiss()
                } else {
                    isMiddlePressed = false
                }
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
        let filteredCategories = databaseManager.categories
            .filter { $0.name.lowercased() != "todas" }
            .sorted { (cat1, cat2) -> Bool in
                if cat1.name.lowercased() == "otra" { return false }
                if cat2.name.lowercased() == "otra" { return true }
                return true
            }
        GenericPickerView(
            title: "NEW_SKILL_SELECT_CATEGORY".localized,
            options: filteredCategories,
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
            if skill == nil {
                createNewAnnounce()
            } else {
                modifyAnnounce()
            }
        } label: {
            Text(skill == nil ? "NEW_SKILL_CREATE_ANNOUNCE".localized : "MODIFY_ANNOUNCE_BUTTON".localized)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .font(.custom(CustomFonts.bold, size: 20))
                .foregroundStyle(ColorManager.defaultWhite)
                .background(isFormValid() ? ColorManager.primaryBasicColor : ColorManager.primaryBasicColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!isFormValid())
    }
    
    /// Delete skill button
    @ViewBuilder
    private var deleteButton: some View {
        Button {
            withAnimation(.easeIn(duration: 0.3)) {
                showAlertDeleteButton = true
            }
        } label: {
            Image(.deleteIcon)
                .resizable()
                .renderingMode(.template)
            
                .frame(width: 30, height: 35)
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .foregroundStyle(ColorManager.defaultWhite)
                .background(ColorManager.cancelColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
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
    
    func initialyseModifyView() {
        if let skill {
            skillName = skill.name
            skillDescription = skill.description
            let numericPart = skill.price.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            price = numericPart
            selectedCategory = skill.category
            let nonNumericPart = skill.price.components(separatedBy: CharacterSet.decimalDigits).joined()
            print(nonNumericPart)
            if nonNumericPart.contains("€/H") {
                selectedPrice = .eurHour
            } else {
                selectedPrice = .eur
            }
            if skill.category.is_manual == nil {
                if let isOnline = skill.is_online {
                    newSkillOnline = isOnline ? .online : .presencial

                }
            }
        }
    }
    
    /// Create announce func
    private func createNewAnnounce() {
        Task {
            // 1. Change isMiddle pressed a false al terminar ejecucion
            defer {
                isMiddlePressed = false
            }
            
            do {
                if let selectedCategory, let selectedPrice {
                    if let _ = selectedCategory.is_manual {
                        try await databaseManager.createNewSkill(skillName: skillName, skillDescription: skillDescription, skillPrice: price, category: selectedCategory, newSkillPrince: selectedPrice)
                    } else {
                        if let isOnline = newSkillOnline {
                            try await databaseManager.createNewSkill(skillName: skillName, skillDescription: skillDescription, skillPrice: price, category: selectedCategory, isOnline: isOnline == .online ? true : false, newSkillPrince: selectedPrice)
                        }
                    }
                }
            } catch {
                print("Error creating skill: \(error.localizedDescription)")
            }
        }
    }
    
    /// Modify announce func
    private func modifyAnnounce() {
        Task {
            defer {
                dismiss()
            }
            do {
                if var skill, let selectedCategory, let selectedPrice {
                    skill.name = skillName
                    skill.category = selectedCategory
                    skill.description = skillDescription
                    skill.price = "\(price) \(selectedPrice.description)"
                    if selectedCategory.is_manual == nil {
                        if newSkillOnline == .online {
                            skill.is_online = true
                        } else {
                            skill.is_online = false
                        }
                    }
                    try await databaseManager.updateSkill(skill: skill)
                }
            } catch {
                print("Error updating data", error)
            }
        }
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
        
        return NewSkillView(isMiddlePressed: $isMiddlePressed, skill: Skill.sample)
            .environmentObject(mockManager)
            .ignoresSafeArea()
        
    }
}
