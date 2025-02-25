//
//  SettingsView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import SwiftUI
import SDWebImageSwiftUI


enum SettingsOptions: Identifiable {
    case terms
    case aboutUs
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .terms:
            return "SETTINGS_TERMS_AND_CONDITIONS".localized
        case .aboutUs:
            return "SETTINGS_CONTACT_ABOUT_US".localized
        }
    }
    
    var bodyText: String {
        switch self {
        case .terms:
            return "TERMS_BODY".localized
        case .aboutUs:
            return "ABOUT_US_BODY".localized
        }
    }
}

struct SettingsView: View {
    
    // MARK: - AUTH MANAGER
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    
    // MARK: - PROXY FROM MAIN
    let proxy: GeometryProxy
    
    // MARK: - DATABASE MANAGER
    @EnvironmentObject var databaseManager: FSDatabaseManager
   
    // MARK: - IMAGE FUNCTIONS
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCropView = false
    @Binding var showImageSourceActionSheet: Bool
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @Binding var showImageBig: Bool
    
    // MARK: - LOGOUT ALERT
    @State private var logoutAlert: Bool = false
    
    // MARK: - ALERT DELETE ACCOUNT
    @State private var showAlertDeleteAcc: Bool = false
    @State private var repeatPass: String = ""
    @State var provider: ProviderResult?
    @State var wrongPassword: Bool = false
    
    // MARK: - SETTINGS OPTIONS
    @State private var settingsOptions: SettingsOptions?
    
    // MARK: - OPEN EDIT PROFILE
    @State private var openEditProfile: Bool = false
    
    // MARK: - NAMESPACE
    let nameSpace: Namespace.ID
    
    // MARK: - NOTIFICATIONS
    @State var toggleNotif: Bool = false
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(alignment: .leading,spacing: 25) {
                    sectionView("PROFILE_HEADER".localized, content: {
                        rowView("EDIT_PROFILE".localized, image: .personIcon, action: {
                            openEditProfile = true
                        })
                        rowView("SETTINGS_LOGOUT".localized, image: .logoutIcon, action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                logoutAlert = true
                            }
                        })
                        rowView("DELETE_ACCOUNT".localized, image: .rubishIcon, action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                Task {
                                    provider = try await authenticatorManager.getProvider()
                                }
                                showAlertDeleteAcc = true
                            }

                        })
                        
                    })
                    sectionView("SETTINGS_NOTIFICATIONS".localized, content: {
                        rowView("SETTINGS_ACTIVATE_NOTIFICATIONS".localized, image: .notificationsIcon, action: {
                            
                        }, isNotifications: true)
                    })
                    
                    sectionView("SETTINGS_TERMS_AND_SUPPORT".localized, content: {
                        rowView("SETTINGS_TERMS_AND_CONDITIONS".localized, image: .termsIcon, action: {
                            settingsOptions = .terms
                        })
                        rowView("SETTINGS_CONTACT_SUPPORT".localized, image: .emailIcon, action: {
                            if let url = URL(string: "mailto:tinktheapp@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        })
                        rowView("SETTINGS_CONTACT_ABOUT_US".localized, image: .infoIcon, action: {
                            settingsOptions = .aboutUs
                        })
                        
                    })
                    
                }
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
                .safeAreaTopPadding(proxy: proxy)
                .safeAreaInset(edge: .bottom) {
                    EmptyView()
                        .frame(height: UIScreen.main.bounds.size.height < 700 ?  Measures.kTabBarHeight - 20:  Measures.kTabBarHeight + 90)
                }
                .safeAreaInset(edge: .top) {
                    EmptyView()
                        .frame(height: Measures.kTopShapeHeight + 30)
                }
                .overlay(alignment: .top) {
                    headerView
                }
            }
            .coordinateSpace(name: "scroll")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorManager.bgColor)
        .overlay {
            if logoutAlert {
                CustomAlert(
                    title: "SETTINGS_LOGOUT".localized,
                    bodyText: "ALERT_LOGOUT_BODY".localized,
                    acceptAction: {
                        Task {
                            try authenticatorManager.signOut()
                        }
                    },
                    cancelAction: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            logoutAlert = false
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
            }
        }
        .overlay {
            if showAlertDeleteAcc {
                if let provider {
                    switch provider {
                    case .google:
                        deleteAccNotAuth
                    case .apple:
                        deleteAccNotAuth
                    case .email:
                        deletAccReauth
                        
                    }
                }
            }
        }
        .sheet(item: $settingsOptions) { option in
            SettingsSheetView(header: option.title, bodyText: option.bodyText)
        }
        .sheet(isPresented: $openEditProfile) {
            EditProfileView()
        }
    }
}

extension SettingsView {
    
    /// Header View
    @ViewBuilder
    private var headerView: some View {
        let height = Measures.kTopShapeHeight + 50
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let dynamicHeight = max(105, max(height + (minY < 0 ? minY : 0), 0))
            let imageOffsetY = max(-10, min(0, minY * 0.2))
            let imageOffsetX = max(0, min(120, minY * -1))
            let progressShape = min(max((minY + 70) / 40, 0), 1)
            let imageSize = max(35, min(90, 90 + minY * 0.35))
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.6))
            let interpolatedOpacity = max(0, min(1, 1 + progress))
            let invertedOpacity = 1 - interpolatedOpacity
            ZStack {
                TopShape(progress: progressShape)
                    .frame(maxWidth: .infinity)
                    .frame(height: dynamicHeight, alignment: .top)
                    .foregroundStyle(ColorManager.primaryBasicColor)
                if !showImageBig {
                    profileImage(size: imageSize)
                        .frame(maxWidth: 70, alignment: .center)
                        .padding(.horizontal, Measures.kHomeHorizontalPadding)
                        .offset(x: imageOffsetX,y: -imageOffsetY)
                }
                if let user = UserDefaults.standard.userSaved {
                    Text(user.name)
                        .padding(.leading, Measures.kHomeHorizontalPadding)
                        .padding(.trailing, UIScreen.main.bounds.size.width / 2.5)
                        .font(.custom(CustomFonts.medium, size: 23))
                        .foregroundStyle(ColorManager.defaultWhite)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(invertedOpacity)
                        .offset(y: -imageOffsetY + 10)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: dynamicHeight, alignment: .top)
            .offset(y: -minY)
        }
        .frame(height: height)
    }
    
    /// Profile Image
    @ViewBuilder
    private func profileImage(size: CGFloat) -> some View {
        Button {
            withAnimation {
                showImageBig = true
            }
        } label: {
            profileImageView(size: size, image: croppedImage ?? UIImage(named: "noProfileIcon"))
        }
        .actionSheet(isPresented: $showImageSourceActionSheet) {
            ActionSheet(
                title: Text("SETTINGS_SELECT_IMAGE".localized),
                message: nil,
                buttons: [
                    .default(Text("SETTINGS_GALLERY".localized)) {
                        imageSource = .photoLibrary
                        showImagePicker = true
                    },
                    .default(Text("SETTINGS_CAMERA".localized)) {
                        imageSource = .camera
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imageSource)
        }
        .fullScreenCover(isPresented: $showCropView) {
            if let image = selectedImage {
                CropImageView(uiImage: image) { cropped in
                    self.croppedImage = cropped
                    showCropView = false
                }
            }
        }
        .onChange(of: croppedImage) {
            if let croppedImage {
                databaseManager.loading = true
                Task {
                    defer { databaseManager.loading = false }
                    if let url = await CloudinaryManager.shared.uploadImage(image: croppedImage) {
                        do {
                            try await databaseManager.uploadUserDefaultsUserImage(imageURL: url)
                            try await databaseManager.updateFirestoreImage(imageURL: url)
                            try await databaseManager.updateFirestoreImageSkill(imageURL: url)
                            print("Updated image in Firestore and UserDefaults")
                        } catch {
                            print("Error updating image in Firestore or UserDefaults: \(error.localizedDescription)")
                        }
                    } else {
                        print("Error updating to Cloudinary")
                    }
                }
            }
        }
        .onChange(of: selectedImage) {
            if selectedImage != nil {
                showCropView = true
            }
        }
    }
    
    /// Profile Image View
    @ViewBuilder
    private func profileImageView(size: CGFloat, image: UIImage?) -> some View {
        // 1. If cropped image we show cropped image
        ZStack {
            Color.clear
                .overlay {
            if let croppedImage = croppedImage {
                Image(uiImage: croppedImage)
                    .resizable()
                   
                    .frame(width: size + 20, height: size + 20)
                    .background(ColorManager.defaultWhite)
                    .clipShape(Circle())
                    .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
                
                // 2. If image save we show image save
            } else if let userImage = UserDefaults.standard.userSaved?.profileImageURL, let url = URL(string: userImage) {
                WebImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                    case .failure:
                        LoadingView()
                    @unknown default:
                        LoadingView()
                    }
                }
                .resizable()
     
                .frame(width: size + 20, height: size + 20)
                .background(ColorManager.defaultWhite)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
                
                
                
                // 3. If no image
            } else {
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    
                    .frame(width: croppedImage != nil ? size + 20 : size, height: croppedImage != nil ? size + 20 : size)
                    .padding(croppedImage != nil ? 0 : 10)
                    .background(ColorManager.defaultWhite)
                    .clipShape(Circle())
                    .shadow(color: ColorManager.primaryGrayColor.opacity(0.5), radius: 3, x: 2, y: 3)
            }
            }
        }
        .matchedGeometryEffect(id: "image", in: nameSpace, isSource: true)
        .transition(.scale(scale: 1))
    }
    
    /// Section View
    @ViewBuilder
    private func sectionView<Content: View>(_ headerText: String,  @ViewBuilder content: () -> Content) -> some View {
        Section {
            content()
        } header: {
            Text(headerText)
                .foregroundStyle(ColorManager.primaryGrayColor)
                .font(.custom(CustomFonts.bold, size: 23))
        }
    }
    
    /// Row View
    @ViewBuilder
    private func rowView(_ text: String, image: ImageResource, action: @escaping () -> Void, isNotifications: Bool = false) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.9))
                Text(text)
                    .font(.custom(CustomFonts.medium, size: 17))
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.9))
                Spacer()
                if isNotifications {
                    Toggle("", isOn: $toggleNotif)
                        .tint(ColorManager.primaryBasicColor)
                        .labelsHidden()
                } else {
                    Image(.backIcon)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(180))
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.9))
                }
              
            }
        }
    }
    
    /// Delete Account Alert
    @ViewBuilder
    private var deleteAccNotAuth: some View {
        CustomAlert(
            title: "DELETE_ACCOUNT".localized,
            bodyText: "SETTINGS_DELETE_BODY".localized,
            acceptAction: {
                Task {
                    do {
                        deleteAccount()
                    }
                }
            },
            cancelAction: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAlertDeleteAcc = false
                    provider = nil
                }
            }
        )
        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
    }
    
    @ViewBuilder
    private var deletAccReauth: some View {
        AlertWithText(
            title: "DELETE_ACCOUNT".localized,
            bodyText: "SETTINGS_DELETE_BODY".localized,
            acceptAction: {
                Task {
                    authenticatorManager.reauthenticate(password: repeatPass) { result in
                        switch result {
                        case .success:
                            do {
                                showAlertDeleteAcc = false
                                deleteAccount()
                            }
                        case .failure:
                            wrongPassword = true
                        }
                    }
                }
                
            },
            cancelAction: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    provider = nil
                    showAlertDeleteAcc = false
                    wrongPassword = false
                    repeatPass = ""
                }
            },
            text: $repeatPass, errorMessage: wrongPassword ? "LOGIN_ERROR_INVALID_PASS".localized : ""
        )
        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
    }
}

// MARK: - PRIVATE FUNCS
extension SettingsView {
    
    private func deleteAccount() {
        databaseManager.loading = true
        defer {
            databaseManager.loading = false
        }
        Task {
            try await authenticatorManager.deleteAccount()
            try await databaseManager.deleteAccount()
            try authenticatorManager.signOut()
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = FSDatabaseManager()
        mockManager.categories = [
            FSCategory(id: "1", name: "Albañilería", is_manual: true),
            FSCategory(id: "2", name: "Carpintería", is_manual: true),
            FSCategory(id: "3", name: "Clases online", is_manual: false),
        ]
        @Previewable @State var showImageBig: Bool = false
        UserDefaults.standard.userSaved = User.sampleUser
        mockManager.allSkillsSaved = Skill.sampleArray
        return GeometryReader { proxy in
            SettingsView(proxy: proxy, showImageSourceActionSheet: .constant(false), showImageBig: $showImageBig, nameSpace: Namespace().wrappedValue)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
