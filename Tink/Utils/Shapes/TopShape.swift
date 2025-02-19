//
//  TopShape.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 10/2/25.
//

import Foundation
import SwiftUI

struct TopShape: Shape {
    var progress: CGFloat = 1

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        let bottomY = height * (0.92 + 0.08 * progress) // Altura inferior ajustada dinámicamente

        path.move(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: bottomY))

        if progress > 0 {
            // Si progress > 0, mantenemos la curva
            let curveFactor = (1 - progress) * 0.4
            path.addCurve(
                to: CGPoint(x: 0, y: bottomY),
                control1: CGPoint(x: width * (0.6 + curveFactor), y: height * (1.2 - curveFactor)),
                control2: CGPoint(x: width * (0.4 - curveFactor), y: height * (0.4 + curveFactor))
            )
        } else {
            // Si progress = 0, dibujamos una línea recta en lugar de una curva
            path.addLine(to: CGPoint(x: 0, y: bottomY))
        }

        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.closeSubpath()

        return path
    }
}

#Preview {
    TopShape()
        .frame(maxWidth: .infinity, maxHeight: 70)
        .foregroundStyle(.red)
}
