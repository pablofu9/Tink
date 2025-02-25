//
//  TabBarView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 7/2/25.
//


import Foundation
import SwiftUI

struct TabBarView: View {
    
    // MARK: - View properties
    @Binding var activeTab: TabModel
    @State var allTabs: [AnimatedTab] = TabModel.allCases.compactMap { tab -> AnimatedTab? in
        return .init(tab: tab)
    }
    @Binding var isMiddlePressed: Bool
    @State private var isRotated: Bool = false
    @Environment(Coordinator<MainCoordinatorPages>.self) private var coordinator

    // MARK: - BODY
    var body: some View {
        content
    }
}

extension TabBarView {
    
    /// Content
    @ViewBuilder
    private var content: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack {
                overlayMiddleButton
                HStack(spacing: 0) {
                    tabButton(animatedTab: $allTabs[0])
                       
                    tabButton(animatedTab: $allTabs[1])
                        .padding(.leading, width / 7)
                    Spacer()
                    tabButton(animatedTab: $allTabs[2])
                        .padding(.trailing, width / 7)
                    tabButton(animatedTab: $allTabs[3])
                }
                .padding(.horizontal, Measures.kHomeHorizontalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: Measures.kTabBarHeight)
                .overlay {
                    CustomTabBarShape()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.2))
                }
                .background {
                    CustomTabBarShape()
                        .fill(ColorManager.defaultWhite)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Measures.kTabBarHeight)
    }
    
    @ViewBuilder
    private func tabButton(animatedTab: Binding<AnimatedTab>) -> some View {
        let tab = animatedTab.wrappedValue.tab
        Button {
            withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
                activeTab = tab
                animatedTab.wrappedValue.isAnimating = true
            }, completion: {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    animatedTab.wrappedValue.isAnimating = nil
                }
            })
        } label: {
            Image(systemName: activeTab == tab ? tab.imageFull : tab.image)
                .resizable()
                .frame(width: 23, height: 23)
                .foregroundStyle(activeTab == tab ? ColorManager.primaryBasicColor : ColorManager.primaryGrayColor.opacity(0.6))
                .symbolEffect(.bounce, value: animatedTab.wrappedValue.isAnimating)
        }
        .padding(.bottom, 15)
    }
    
    @ViewBuilder
    private var overlayMiddleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                isMiddlePressed = true
                coordinator.push(.newAnnounce)
            }
        } label: {
            Image(.plusIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: 30, height: 30)
                .foregroundStyle(ColorManager.defaultWhite)
                .padding(20)
                .background(ColorManager.primaryBasicColor)
                .clipShape(Circle())
                .shadow(color: ColorManager.primaryGrayColor.opacity(0.3), radius: 2, x: 0, y: -2)
        }
        .offset(y: -35)
    }
}


struct TabBarViewPreview: View {
    @State private var selectedTab: TabModel = .home
    @State private var isMiddle: Bool = false

    var body: some View {
        TabBarView(activeTab: $selectedTab, isMiddlePressed: $isMiddle)
    }
}

#Preview {
    ZStack {
        Color.red
        TabBarViewPreview()
    }

}
