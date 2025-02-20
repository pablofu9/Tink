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
    
    @State private var name: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: EditProfileFocus?
    
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
                emailView
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
                email = user.email
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
    private var emailView: some View {
        VStack(alignment: .leading, spacing: 5) {
            headerView("LOGIN_EMAIL".localized)
            TextField("", text: $email, prompt: propmtView("LOGIN_EMAIL".localized))
                .textFieldStyle(LoginTextField(focused: focus == .email))
                .focused($focus, equals: .email)
        }
    }
    
    @ViewBuilder
    private var updateButton: some View {
        Button {
            
        } label: {
            Text("PROFILE_UPDATE_PROFILE".localized)
                .font(.custom(CustomFonts.medium, size: 18))
                .foregroundStyle(ColorManager.defaultWhite)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
                .background(ColorManager.primaryBasicColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    EditProfileView()
}
