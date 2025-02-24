////
////  CompleteProfileView.swift
////  Tink
////
////  Created by Pablo Fuertes ruiz on 12/2/25.
////
//
//import SwiftUI
//
//struct CompleteProfileView: View {
//    
//    // MARK: - Focus state enum
//    enum CoompleteProfileFocused {
//        case name
//        case surname
//    }
//    
//    // MARK: - BLOB PROPERTIES
//    @State private var position1 = CGPoint(x: 0, y: 0)
//    @State private var position2 = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
//    @State private var position3 = CGPoint(x: 0, y: 0)
//    @State private var position4 = CGPoint(x: UIScreen.main.bounds.width, y: 0)
//    @State private var timer: Timer? = nil
//    @State private var proxySize: CGSize = .zero
//    
//    // MARK: - FORM PROPERTIES
//    @FocusState var focus: CoompleteProfileFocused?
//    @StateObject var provincesHelper = ProvincesHelper()
//    @State var selectedCommunity: AutonomousCommunity?
//    @State var provinceSelected: Province?
//    @State var selectedTown: Town?
//    @State private var name: String = ""
//    @State private var surname: String = ""
//
//    // MARK: - DATABASE MANAGER
//    @EnvironmentObject var databaseManager: FSDatabaseManager
//
//    
//    // MARK: - BODY
//    var body: some View {
//        content
//            .overlay {
//                if provincesHelper.loading {
//                    LoadingView()
//                }
//            }
//    }
//}
//
//
//// MARK: - SUBVIEWS
//extension CompleteProfileView {
//    
//    @ViewBuilder
//    private var content: some View {
//        GeometryReader { proxy in
//            blobBG(proxy)
//            ScrollView {
//                LazyVStack(alignment: .leading,spacing: 20) {
//                    Section {
//                        nameView
//                        surnameView
//                        communitySelector
//                        provinceTownsSelector
//                        Spacer()
//                        continueButton
//                            .padding(.bottom, 60)
//                    } header: {
//                        VStack(alignment: .leading) {
//                            Text("COMPLETE_PROFILE".localized)
//                                .font(.custom(CustomFonts.bold, size: 27))
//                                .foregroundStyle(ColorManager.primaryGrayColor)
//                            Text("NEED_COMPLETE_PROFILE".localized)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .background(.clear)
//                    }
//                }
//            }
//            .ignoresSafeArea()
//            .safeAreaVerticalPadding(proxy: proxy)
//            .padding(.horizontal, Measures.kHomeHorizontalPadding - 3)
//            .scrollIndicators(.hidden)
//            .onAppear {
//                self.proxySize = proxy.size
//                Task {
//                    provincesHelper.loadCommunities()
//                }
//                startRandomMovement()
//            }
//           
//        }
//        .background(ColorManager.defaultWhite)
//        .onTapGesture {
//            focus = nil
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//    }
//    
//    @ViewBuilder
//    private func blobBG(_ proxy: GeometryProxy) -> some View {
//        ZStack(alignment: .topLeading) {
//            
//            CustomBlob()
//                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
//                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.3))
//                .position(position1)
//            
//            // Segundo blob
//            CustomBlob()
//                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
//                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.4))
//                .rotationEffect(.degrees(180))
//                .position(position2)
//            
//            // Tercer blob
//            CustomBlob()
//                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
//                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.5))
//                .rotationEffect(.degrees(90))
//                .position(position3)
//            
//            CustomBlob()
//                .frame(width: proxy.size.width / 3, height: proxy.size.width / 3)
//                .foregroundStyle(ColorManager.primaryBasicColor.opacity(0.4))
//                .rotationEffect(.degrees(120))
//                .position(position4)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//    }
//    
//    @ViewBuilder
//    private var nameView: some View {
//        VStack(alignment: .leading ,spacing: 3) {
//            Text("NAME".localized)
//                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
//                .font(.custom(CustomFonts.regular, size: 17))
//            TextField("", text: $name, prompt: propmtView("TYPE_NAME".localized))
//                .textFieldStyle(LoginTextField(focused: focus == .name))
//                .focused($focus, equals: .name)
//                .onSubmit {
//                    focus = .surname
//                }
//                .submitLabel(.continue)
//        }
//        .padding(.horizontal, 3)
//    }
//    
//    @ViewBuilder
//    private var surnameView: some View {
//        VStack(alignment: .leading ,spacing: 3) {
//            Text("SURNAME".localized)
//                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.8))
//                .font(.custom(CustomFonts.regular, size: 17))
//            TextField("", text: $surname, prompt: propmtView("TYPE_SURNAME".localized))
//                .textFieldStyle(LoginTextField(focused: focus == .surname))
//                .focused($focus, equals: .surname)
//                .onSubmit {
//                    focus = nil
//                }
//                .submitLabel(.done)
//        }
//        .padding(.horizontal, 3)
//    }
//    
//    @ViewBuilder
//    private var communitySelector: some View {
//        GenericPickerView(
//            title: "COMMUNITY_AUT".localized,
//            options: provincesHelper.communities,
//            selectedOption: $selectedCommunity
//        )
//        .padding(.horizontal, 3)
//        .onChange(of: selectedCommunity) {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                if let selectedCommunity {
//                    resetOnCommunityChange()
//                    provincesHelper.getProvinces(comunity: selectedCommunity)
//                } else {
//                    resetOnCommunityChange()
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var provincesSelector: some View {
//        GenericPickerView(
//            title: "PROVINCE".localized,
//            options: provincesHelper.provinces,
//            selectedOption: $provinceSelected
//        )
//        .padding(.horizontal, 3)
//        .onChange(of: provinceSelected) {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                if let provinceSelected {
//                    resetOnProvinceChange()
//                    provincesHelper.getTowns(province: provinceSelected)
//                } else {
//                    resetOnProvinceChange()
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var townSelector: some View {
//        GenericPickerView(
//            title: "LOCALITY".localized,
//            options: provincesHelper.towns,
//            selectedOption: $selectedTown
//        )
//        .padding(.horizontal, 3)
//    }
//    
//    @ViewBuilder
//    private var provinceTownsSelector: some View {
//        HStack(spacing: 10) {
//            provincesSelector
//            townSelector
//        }
//    }
//    
//    @ViewBuilder
//    private var continueButton: some View {
//        Button {
//            Task {
//                if let selectedCommunity, let provinceSelected, let selectedTown {
//                    try await databaseManager.createNewUser(name: name, surname: surname, community: selectedCommunity.label, province: provinceSelected.label, locality: selectedTown.label)
//                }
//            }
//        } label: {
//            Text("CONTINUE".localized)
//                .padding(.vertical, 10)
//                .frame(maxWidth: .infinity)
//                .font(.custom(CustomFonts.bold, size: 20))
//                .foregroundStyle(ColorManager.defaultWhite)
//                .background(isFormValid() ? ColorManager.primaryBasicColor : ColorManager.primaryBasicColor.opacity(0.5))
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//        }
//        .disabled(!isFormValid())
//    }
//    
//    @ViewBuilder
//    private func propmtView(_ text: String) -> Text {
//        Text(text)
//            .font(.custom(CustomFonts.regular, size: 17))
//            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.6))
//    }
//    
//}
//
//// MARK: - PRIVATE FUNCS
//extension CompleteProfileView {
//    
//    /// Star random blob movement
//    func startRandomMovement() {
//        timer?.invalidate() // 1. Cancel previous timer
//
//        // 2. Configure timer each x seconds
//        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//            // 3. generate new positions randomly
//            withAnimation(.easeInOut(duration: 10)) {
//                position1 = CGPoint(
//                    x: CGFloat.random(in: 0...proxySize.width),
//                    y: CGFloat.random(in: 0...proxySize.height)
//                )
//                position2 = CGPoint(
//                    x: CGFloat.random(in: 0...proxySize.width),
//                    y: CGFloat.random(in: 0...proxySize.height)
//                )
//                position3 = CGPoint(
//                    x: CGFloat.random(in: 0...proxySize.width),
//                    y: CGFloat.random(in: 0...proxySize.height)
//                )
//                position4 = CGPoint(
//                    x: CGFloat.random(in: 0...proxySize.width),
//                    y: CGFloat.random(in: 0...proxySize.height)
//                )
//            }
//        }
//    }
//    
//    private func resetOnCommunityChange() {
//        provincesHelper.removeProvinces()
//        provincesHelper.removeTowns()
//        selectedTown = nil
//        provinceSelected = nil
//    }
//    
//    private func resetOnProvinceChange() {
//        provincesHelper.removeTowns()
//        selectedTown = nil
//    }
//    
//    // Check if its form valid
//    func isFormValid() -> Bool {
//        return selectedCommunity != nil &&
//        provinceSelected != nil &&
//        selectedTown != nil &&
//        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
//        !surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//}
//
//
//#Preview {
//    CompleteProfileView()
//        .environmentObject(FSDatabaseManager())
//}
//
