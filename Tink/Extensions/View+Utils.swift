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
        self.padding(.vertical, proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top :0)
    }
}

extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) { 
                text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
}

extension View {
    @ViewBuilder
    func cropImagePicker(options: [Crop], show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        
    }
}

enum Crop: Equatable {
    case circle
    
    func name() -> String {
        switch self {
        case .circle:
            return "Circle"
        }
    }
    
    func size() -> CGSize {
        switch self {
        case .circle:
            return .init(width: 60, height: 60)
        }
    }
}

// MARK: - TOAST EXTENSION
extension View {
    func toast(isShowing: Binding<Bool>, message: String, duration: TimeInterval = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, duration: duration))
    }
}
