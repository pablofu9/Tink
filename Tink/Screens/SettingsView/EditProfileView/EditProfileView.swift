//
//  EditProfileView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 20/2/25.
//

import SwiftUI

enum EditProfileFocus {
    case name
    case email
}

struct EditProfileView: View {
    
    // Name view
    @State private var name: String = ""
    // Dismiss
    @Environment(\.dismiss) var dismiss
    // Focus
    @FocusState var focus: EditProfileFocus?
    // Database manager
    @EnvironmentObject var databaseManager: FSDatabaseManager
    // Button disabled
    var isDisabled: Bool {
        return name.isEmpty
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            BackButton(action: {
                dismiss()
            })
            
            Text("EDIT_PROFILE".localized)
                .font(.custom(CustomFonts.bold, size: 22))
                .foregroundStyle(ColorManager.defaultBlack)
            LazyVStack(alignment: .leading, spacing: 35) {
                nameView
                updateButton
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, Measures.kHomeHorizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(ColorManager.bgColor)
        .onAppear {
            if let user = UserDefaults.standard.userSaved {
                name = user.name
            }
        }
        .overlay {
            if databaseManager.loading {
                LoadingView()
            }
        }
    }
}

// MARK: - SUBVIEWS
extension EditProfileView {
    
    @ViewBuilder
    private func propmtView(_ text: String) -> Text {
        Text(text)
            .font(.custom(CustomFonts.regular, size: 17))
            .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.6))
    }
    
    @ViewBuilder
    private func headerView(_ text: String) -> some View {
        Text(text)
            .font(.custom(CustomFonts.medium, size: 18))
            .foregroundStyle(ColorManager.primaryGrayColor.opacity(1))
    }
    
    @ViewBuilder
    private var nameView: some View {
        VStack(alignment: .leading, spacing: 5) {
            headerView("NAME".localized)
            TextField("", text: $name, prompt: propmtView("NAME".localized))
                .textFieldStyle(LoginTextField(focused: focus == .name))
                .focused($focus, equals: .name)
        }
    }
    
    
    @ViewBuilder
    private var updateButton: some View {
        Button {
            if !name.isEmpty {
                Task {
                    try await databaseManager.updateName(name: name)
                }
            }
        } label: {
            Text("PROFILE_UPDATE_PROFILE".localized)
                .font(.custom(CustomFonts.medium, size: 18))
                .foregroundStyle(ColorManager.defaultWhite)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
                .background(ColorManager.primaryBasicColor.opacity(isDisabled ? 0.5 : 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(isDisabled)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}


#Preview {
    let mockManager = FSDatabaseManager()
    EditProfileView()
        .environmentObject(mockManager)
        
}
