//
//  SettingsView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(AuthenticatorManager.self) private var authenticatorManager
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                Task {
                    try authenticatorManager.signOut()
                }
            }
    }
}

#Preview {
    SettingsView()
        .environment(AuthenticatorManager())

}
