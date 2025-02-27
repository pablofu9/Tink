//
//  MainCoordinatorPages.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 25/2/25.
//


import Foundation
import SwiftUI

enum MainCoordinatorPages: Coordinatable, Equatable {
    nonisolated var id: UUID { .init() }

    case root
    case newAnnounce
    case chatDetail(chat: Chat, user: User)
    case skillDetail(skill: Skill, activeTab: Binding<TabModel>)
    
    var body: some View {
        switch self {
        case .root:
            MainView()
        case .newAnnounce:
            NewSkillView()
        case .chatDetail(let chat, let user):
            ChatDetailView(chat: chat, userNotUs: user)
        case .skillDetail(let skill, let activeTab):
            SkillDetailView(skill: skill, activeTab: activeTab)
        }
    }

    // Implement Equatable
    static func == (lhs: MainCoordinatorPages, rhs: MainCoordinatorPages) -> Bool {
        switch (lhs, rhs) {
        case (.root, .root):
            return true
        case (.newAnnounce, .newAnnounce):
            return true
        case let (.chatDetail(chat1, user1), .chatDetail(chat2, user2)):
            return chat1 == chat2 && user1 == user2
        default:
            return false
        }
    }

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .root:
            hasher.combine("root")
        case .newAnnounce:
            hasher.combine("newAnnounce") 
        case let .chatDetail(chat, user):
            hasher.combine("chatDetail")
            hasher.combine(chat)
            hasher.combine(user)
        case let .skillDetail(skill, _):
            hasher.combine(skill)
        }
    }
}
