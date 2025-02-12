//
//  CompleteProfileView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import SwiftUI

struct CompleteProfileView: View {
    
    // MARK: - Focus state enum
    enum CoompleteProfileFocused {
        case name
        case dni
    }
    
    // MARK: - BLOB PROPERTIES
    @State private var position1 = CGPoint(x: 0, y: 0)
    @State private var position2 = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    @State private var position3 = CGPoint(x: 0, y: 0)
    @State private var position4 = CGPoint(x: UIScreen.main.bounds.width, y: 0)
    @State private var timer: Timer? = nil
    @State private var proxySize: CGSize = .zero
    
    // MARK: - FORM PROPERTIES
    @FocusState var focus: CoompleteProfileFocused?
    @StateObject var provincesHelper = ProvincesHelper()
    @State var selectedCommunity: AutonomousCommunity?
    @State var provinceSelected: Province?
    @State var selectedTown: Town?
    @State private var name: String = ""
    @State private var DNI: String = ""

    // MARK: - DATABASE MANAGER
    @EnvironmentObject var databaseManager: FSDatabaseManager

    // MARK: - CHECK IF IS MIDDLE
    @Binding var isMiddlePressed: Bool
    
    // MARK: - BODY
    var body: some View {
        GeometryReader { proxy in
            blobBG(proxy)
            ScrollView {
                LazyVStack(spacing: 20) {
                    nameView
                    dniView
                    communitySelector
                    provinceTownsSelector
                }
            }
            .safeAreaVerticalPadding(proxy: proxy)
            .padding(.top, 100)
            .padding(.horizontal, Measures.kHomeHorizontalPadding - 3)
            .scrollIndicators(.hidden)
            .onAppear {
                self.proxySize = proxy.size
                Task {
                    provincesHelper.loadCommunities()
                }
                startRandomMovement()
            }
        }
        .background(ColorManager.defaultWhite)
        .overlay(alignment: .bottom) {
            continueButton
                .padding(.bottom, 70)
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
        }
        .onTapGesture {
            focus = nil
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - SUBVIEWS
extension CompleteProfileView {
    
    @ViewBuilder
    private func blobBG(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .topLeading) {
           
            CustomBlob()
                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.5))
                .position(position1)
            
            // Segundo blob
            CustomBlob()
                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.6))
                .rotationEffect(.degrees(180))
                .position(position2)
            
            // Tercer blob
            CustomBlob()
                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.7))
                .rotationEffect(.degrees(90))
                .position(position3)
            
            CustomBlob()
                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.4))
                .rotationEffect(.degrees(120))
                .position(position4)
            HStack(spacing: 10) {
                if isMiddlePressed {
                    backIcon
                }
                Text("COMPLETE_PROFILE".localized)
                    .font(.custom(CustomFonts.bold, size: 27))
                    .foregroundStyle(ColorManager.primaryGrayColor)
            }
            .position(x: proxy.size.width / 2.5, y: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    @ViewBuilder
    private var nameView: some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text("NAME".localized)
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                .font(.custom(CustomFonts.regular, size: 17))
            TextField("", text: $name)
                .textFieldStyle(LoginTextField(focused: focus == .name))
                .focused($focus, equals: .name)
                .onSubmit {
                    focus = .dni
                }
                .submitLabel(.continue)
        }
        .padding(.horizontal, 3)
    }
    
    @ViewBuilder
    private var dniView: some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text("DNI_NIE".localized)
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                .font(.custom(CustomFonts.regular, size: 17))
            TextField("", text: $DNI)
                .textFieldStyle(LoginTextField(focused: focus == .dni))
                .focused($focus, equals: .dni)
                .onSubmit {
                    focus = nil
                }
                .submitLabel(.done)
        }
        .padding(.horizontal, 3)
    }
    
    @ViewBuilder
    private var communitySelector: some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text("COMMUNITY_AUT".localized)
                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                .font(.custom(CustomFonts.regular, size: 17))
            Picker("", selection: $selectedCommunity) {
                Text("SELECTE_COMUNNITY".localized)
                    .tag(nil as AutonomousCommunity?)
                    .foregroundStyle(ColorManager.primaryGrayColor)
                ForEach(provincesHelper.communities, id: \.self) { community in
                    Text(community.label)
                        .font(.custom(CustomFonts.bold, size: 12))
                        .foregroundStyle(ColorManager.primaryGrayColor)
                        .tag(community)
                }
            }
            .labelsHidden()
            .accentColor(ColorManager.primaryGrayColor)
            .pickerStyle(MenuPickerStyle())
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(ColorManager.primaryGrayColor)
            }
            .padding(.horizontal, 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: selectedCommunity) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if let selectedCommunity {
                    resetOnCommunityChange()
                    provincesHelper.getProvinces(comunity: selectedCommunity)
                } else {
                    resetOnCommunityChange()
                }
            }
        }
    }
    
    @ViewBuilder
    private var provincesSelector: some View {
        if !provincesHelper.provinces.isEmpty {
            VStack(alignment: .leading ,spacing: 3) {
                Text("PROVINCE".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                    .font(.custom(CustomFonts.regular, size: 17))
                Picker("", selection: $provinceSelected) {
                    Text("PROVINCE".localized)
                        .tag(nil as Province?)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                    ForEach(provincesHelper.provinces, id: \.self) { province in
                        Text(province.label)
                            .font(.custom(CustomFonts.bold, size: 12))
                            .foregroundStyle(ColorManager.primaryGrayColor)
                            .tag(province)
                    }
                }
                .labelsHidden()
                .accentColor(ColorManager.primaryGrayColor)
                .pickerStyle(MenuPickerStyle())
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
                .padding(.leading, 3)
            }
            .onChange(of: provinceSelected) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if let provinceSelected {
                        resetOnProvinceChange()
                        provincesHelper.getTowns(province: provinceSelected)
                    } else {
                        resetOnProvinceChange()
                    }
                }
            }
            .transition(.opacity)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var townSelector: some View {
        if !provincesHelper.towns.isEmpty {
            VStack(alignment: .leading ,spacing: 3) {
                Text("LOCALITY".localized)
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
                    .font(.custom(CustomFonts.regular, size: 17))
                Picker("", selection: $selectedTown) {
                    Text("LOCALITY".localized)
                        .tag(nil as Town?)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                    ForEach(provincesHelper.towns, id: \.self) { town in
                        Text(town.label)
                            .font(.custom(CustomFonts.bold, size: 12))
                            .foregroundStyle(ColorManager.primaryGrayColor)
                            .tag(town)
                    }
                }
                .labelsHidden()
                .accentColor(ColorManager.primaryGrayColor)
                .pickerStyle(MenuPickerStyle())
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor)
                }
            }
            .padding(.trailing, 3)
            .transition(.opacity)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var provinceTownsSelector: some View {
        HStack(spacing: 10) {
            provincesSelector
            townSelector
        }
    }
    
    @ViewBuilder
    private var continueButton: some View {
        Button {
            Task {
                if let selectedCommunity, let provinceSelected, let selectedTown {
                    try await databaseManager.createNewUser(name: name, dni: DNI, community: selectedCommunity.label, province: provinceSelected.label, locality: selectedTown.label)
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    databaseManager.goCompleteProfile = false
                }
            }
        } label: {
            Text("CONTINUE".localized)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .font(.custom(CustomFonts.bold, size: 20))
                .foregroundStyle(ColorManager.defaultWhite)
                .background(isFormValid() ? ColorManager.primaryBasicColor : ColorManager.primaryBasicColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!isFormValid())
    }
    
    /// Back icon
    @ViewBuilder
    private var backIcon: some View {
        BackButton(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                databaseManager.goCompleteProfile = false
                isMiddlePressed = false
            }
        })
    }
}

// MARK: - PRIVATE FUNCS
extension CompleteProfileView {
    
    /// Star random blob movement
    func startRandomMovement() {
        timer?.invalidate() // 1. Cancel previous timer

        // 2. Configure timer each x seconds
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            // 3. generate new positions randomly
            withAnimation(.easeInOut(duration: 10)) {
                position1 = CGPoint(
                    x: CGFloat.random(in: 0...proxySize.width),
                    y: CGFloat.random(in: 0...proxySize.height)
                )
                position2 = CGPoint(
                    x: CGFloat.random(in: 0...proxySize.width),
                    y: CGFloat.random(in: 0...proxySize.height)
                )
                position3 = CGPoint(
                    x: CGFloat.random(in: 0...proxySize.width),
                    y: CGFloat.random(in: 0...proxySize.height)
                )
                position4 = CGPoint(
                    x: CGFloat.random(in: 0...proxySize.width),
                    y: CGFloat.random(in: 0...proxySize.height)
                )
            }
        }
    }
    
    private func resetOnCommunityChange() {
        provincesHelper.removeProvinces()
        provincesHelper.removeTowns()
        selectedTown = nil
        provinceSelected = nil
    }
    
    private func resetOnProvinceChange() {
        provincesHelper.removeTowns()
        selectedTown = nil
    }
    
    // Check if its form valid
    func isFormValid() -> Bool {
        return selectedCommunity != nil &&
        provinceSelected != nil &&
        selectedTown != nil &&
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !DNI.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


#Preview {
    @Previewable @State  var isMiddle: Bool = false
    CompleteProfileView(isMiddlePressed: $isMiddle)
        .environmentObject(FSDatabaseManager())
}

