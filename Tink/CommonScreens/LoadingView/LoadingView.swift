//
//  LoadingView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            ColorManager.secondaryGrayColor
                .opacity(0.7)
            LottieView(animationFileName: "loading", loopMode: .loop)
                .frame(width: 30, height: 30)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
