//
//  ProfileView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    // MARK: - VIEW PROPERTIES
    let proxy: GeometryProxy
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    @EnvironmentObject var databaseManager: FSDatabaseManager
    
    // MARK: - TOGGLE VIEW
    @State var toggleView: Bool = false
    
    // MARK: - CONTROL MODIFY SKILL
    @State var selectedSkillToModify: Skill?
    
    // MARK: - CAMERA MANAGER
    @StateObject var cameraManager = CameraManager()
    
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCropView = false
    
    // MARK: - BODY
    var body: some View {
        content
    }
}

// MARK: - SUBVIEWS
extension ProfileView {
    
    /// Content view
    @ViewBuilder
    private var content: some View {
        ZStack(alignment: .top) {
            ScrollView {
                if let _ = UserDefaults.standard.userSaved {
                    LazyVStack(alignment: .leading,spacing: 20) {
                        skillsView
                        informationView
                    }
                    .safeAreaInset(edge: .top) {
                        EmptyView()
                            .frame(height: Measures.kTopShapeHeightSmaller - 40)
                    }
                    .safeAreaInset(edge: .bottom) {
                        EmptyView()
                            .frame(height: Measures.kTabBarHeight + 60)
                    }
                    .safeAreaTopPadding(proxy: proxy)
                    .overlay(alignment: .top) {
                        profileHeader(proxy)
                    }
                }
            }
            .coordinateSpace(name: "SCROLL")
        }
        .sheet(item: $selectedSkillToModify) { skill in
            NewSkillView(isMiddlePressed: .constant(false), skill: skill)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorManager.bgColor)
    }
    
    /// Header View
    @ViewBuilder
    private func profileHeader(_ proxy: GeometryProxy) -> some View {
        let height = Measures.kTopShapeHeightSmaller
        GeometryReader { reader in
            let minY = reader.frame(in: .named("SCROLL")).minY
            let dynamicHeight = max(105, max(height + (minY < 0 ? minY : 0), 0))
            let textOffsetY = max(-22, min(0, minY * 0.2))
            let imageOffsetY = max(-15, min(0, minY * 0.2))
            let progressShape = min(max((minY + 70) / 40, 0), 1)
            let imageSize = max(30, min(50, 50 + minY * 0.2))
            ZStack(alignment: .trailing) {
                TopShape(progress: progressShape)
                    .frame(maxWidth: .infinity)
                    .frame(height: dynamicHeight, alignment: .top)
                    .foregroundStyle(ColorManager.primaryBasicColor)
                Text("PROFILE_HEADER".localized)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(CustomFonts.bold, size: 30))
                    .foregroundStyle(ColorManager.defaultWhite)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .offset(y: -textOffsetY)
                
                profileImage(size: imageSize)
                    .frame(maxWidth: 70, alignment: .leading)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                    .offset(y: -imageOffsetY)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: dynamicHeight, alignment: .top)
            .offset(y: -minY)

        }
        .frame(height: height)
    }
    
    /// Top shape view
    @ViewBuilder
    private func topShape(_ curvedHeight: CGFloat) -> some View {
        TopShape()
            .frame(maxWidth: .infinity)
            .frame(height: curvedHeight, alignment: .top)
            .foregroundStyle(ColorManager.primaryBasicColor)
    }
    
    /// Custom Row View
    @ViewBuilder
    private func rowView(name: String, text: String, udText: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Image(systemName: name)
                    .foregroundStyle(ColorManager.primaryBasicColor)
                Text(text)
                    .font(.custom(CustomFonts.regular, size: 18))
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.6))
            }

                Text(udText)
                    .font(.custom(CustomFonts.regular, size: 19))
                    .foregroundStyle(ColorManager.defaultBlack)
                Divider()
            
        }
    }
    
    
    /// Skills view
    @ViewBuilder
    private var skillsView: some View {
        if !databaseManager.filteredSkills.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text("PROFILE_YOUR_SKILLS".localized)
                    .font(.custom(CustomFonts.bold, size: 25))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                    .padding(.horizontal, Measures.kHomeHorizontalPadding)
                Button {
                    if databaseManager.currentIndex <= databaseManager.filteredSkills.count {
                        selectedSkillToModify = databaseManager.filteredSkills[databaseManager.currentIndex]
                    }
                } label: {
                    SkillCarouselView(selectedIndex: $databaseManager.currentIndex)
                }
            }
        }

    }
    
    /// Information view
    @ViewBuilder
    private var informationView: some View {
        if let profileSaved = UserDefaults.standard.userSaved {
            VStack(alignment: .leading, spacing: 15) {
                Text("PROFILE_YOUR_INFORMATION".localized)
                    .font(.custom(CustomFonts.bold, size: 25))
                    .foregroundStyle(ColorManager.primaryGrayColor)
                rowView(name: "person.fill", text: "NAME".localized, udText: "\(profileSaved.name)")
                rowView(name: "envelope.fill", text: "LOGIN_EMAIL".localized, udText: profileSaved.email)
                rowView(name: "map.fill", text: "LOCALITY".localized, udText: "\(profileSaved.locality), \(profileSaved.province)")
            }
            .padding(.horizontal, Measures.kHomeHorizontalPadding)
        }
    }

    @ViewBuilder
    private func profileImage(size: CGFloat) -> some View {
        Button {
            showImagePicker = true
        } label: {
            profileImageView(size: size, image: croppedImage ?? UIImage(named: "noProfileIcon"))
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
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
                    defer { databaseManager.loading = false}
                    if let url = await CloudinaryManager.shared.uploadImage(image: croppedImage) {
                        do {
                            try await databaseManager.uploadUserDefaultsUserImage(imageURL: url)
                            try await databaseManager.updateFirestoreImage(imageURL: url)
                            try await databaseManager.updateFirestoreImageSkill(imageURL: url)
                            print("Updated image in Firestore and UserDefaults")
                        } catch {
                            print("Error updating image in firesotre or UserDefaults: \(error.localizedDescription)")
                        }
                    } else {
                        print("Error Updating to Cloduinary")
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
    
    @ViewBuilder
    private func profileImageView(size: CGFloat, image: UIImage?) -> some View {
        // 1. If cropped image we show cropped image
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


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = FSDatabaseManager()
        UserDefaults.standard.userSaved = User.sampleUser
     //   mockManager.skillsSaved = Skill.sampleArray
        return GeometryReader { proxy in
            ProfileView(proxy: proxy)
                .environment(AuthenticatorManager())
                .environmentObject(mockManager)
                .ignoresSafeArea()
        }
        .previewLayout(.sizeThatFits)
    }
}
