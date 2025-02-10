//
//  TabModel.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 7/2/25.
//

import Foundation


enum TabModel: String, CaseIterable {
    
    case home
    case chat
    case profile
    case settings
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .chat: return "Chat"
        case .profile: return "Perfil"
        case .settings: return "Ajustes"
        }
    }
    
    var image: String {
        switch self {
        case .home: return "house"
        case .chat: return "message"
        case .profile: return "person"
        case .settings: return "gearshape"
        }
    }
    
    var imageFull: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: TabModel
    var isAnimating: Bool?
}
