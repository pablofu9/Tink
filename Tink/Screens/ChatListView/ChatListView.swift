//
//  ChatListView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 18/2/25.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var chatManager = ChatManager()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ChatListView()
}
