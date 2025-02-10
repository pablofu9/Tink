//
//  View+Utils.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import SwiftUI

extension View {
    func safeAreaBottomPadding(proxy: GeometryProxy) -> some View {
        self.padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? proxy.safeAreaInsets.bottom : Measures.kVerticalPaddingIfNoSafeArea)
    }
}

extension View {
    func safeAreaTopPadding(proxy: GeometryProxy) -> some View {
        self.padding(.top, proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : Measures.kVerticalPaddingIfNoSafeArea)
    }
}

extension View {
    func safeAreaVerticalPadding(proxy: GeometryProxy) -> some View {
        self.padding(.vertical, proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : Measures.kVerticalPaddingIfNoSafeArea)
    }
}
