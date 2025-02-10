//
//  TopShape.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import Foundation
import SwiftUI

struct TopShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 1.00024*width, y: 0.00434*height))
        path.addLine(to: CGPoint(x: 0.9999*width, y: 0.92493*height))
        path.addCurve(to: CGPoint(x: -0.0001*width, y: 0.92059*height), control1: CGPoint(x: 0.60648*width, y: 1.22964*height), control2: CGPoint(x: 0.39526*width, y: 0.3932*height))
        path.addLine(to: CGPoint(x: 0.00024*width, y: 0))
        path.addLine(to: CGPoint(x: 1.000*width, y: 0.00*height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    TopShape()
        .frame(maxWidth: .infinity, maxHeight: 70)
        .foregroundStyle(.red)
}
