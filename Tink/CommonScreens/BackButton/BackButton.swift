//
//  BackButton.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import Foundation
import SwiftUI

struct BackButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(ColorManager.secondaryGrayColor.opacity(0.6))
                Image(.backIcon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 35, height: 35)
                    .foregroundStyle(ColorManager.defaultBlack)
            }
        }
    }
}

