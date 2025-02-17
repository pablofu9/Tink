//
//  OnlineFilterView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 17/2/25.
//

import SwiftUI

// Home online state tracker for filter
enum HomeOnlineState: CaseIterable {
    case online
    case inPerson
    case all
    
    var description: String {
        switch self {
        case .online:
            return "NEW_SKILL_ONLINE".localized
        case .inPerson:
            return "NEW_SKILL_PRESENCIAL".localized
        case .all:
            return "NEW_SKILL_BOTH".localized 
        }
    }
}

struct OnlineFilterView: View {
    
    @Binding var onlineState: HomeOnlineState
    
    var body: some View {
        homeOnlineChooser
    }
    
    @ViewBuilder
    private var homeOnlineChooser: some View {
        HStack(spacing: 5) {
            ForEach(HomeOnlineState.allCases.sorted {
                $0.description.localizedCaseInsensitiveCompare($1.description) == .orderedAscending
            }, id: \.self) { state in
                Button {
                    withAnimation(.easeIn(duration: 0.2)) {
                        onlineState = state
                    }
                } label: {
                    Text(state.description)
                        .font(.custom(CustomFonts.regular, size: 18))
                        .foregroundStyle(onlineState == state ? ColorManager.defaultWhite : ColorManager.primaryGrayColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 2)
                        .background {
                            if onlineState == state {
                                Capsule()
                                    .fill(ColorManager.primaryBasicColor)
                                    .transition(.blurReplace)
                            }
                            Capsule()
                                .stroke(lineWidth: 1)
                                .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.5))
                        }
                        .padding(.vertical, 3)
                }
            }
        }
        .safeAreaInset(edge: .leading) {
            Color.clear
                .frame(width: Measures.kHomeHorizontalPadding, height: 0)
        }
        .safeAreaInset(edge: .trailing) {
            Color.clear
                .frame(width: Measures.kHomeHorizontalPadding, height: 0)
        }
    }
}

#Preview {
    OnlineFilterView(onlineState: .constant(.inPerson))
}
