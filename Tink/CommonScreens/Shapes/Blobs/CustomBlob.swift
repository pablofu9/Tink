//
//  CustomBlob.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 12/2/25.
//

import Foundation
import SwiftUI

struct CustomBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.44092*width, y: 0.00682*height))
        path.addCurve(to: CGPoint(x: 0.71146*width, y: 0.26238*height), control1: CGPoint(x: 0.57714*width, y: 0.03422*height), control2: CGPoint(x: 0.62215*width, y: 0.17284*height))
        path.addCurve(to: CGPoint(x: 0.88447*width, y: 0.45152*height), control1: CGPoint(x: 0.77381*width, y: 0.32489*height), control2: CGPoint(x: 0.83961*width, y: 0.37945*height))
        path.addCurve(to: CGPoint(x: 0.99668*width, y: 0.7206*height), control1: CGPoint(x: 0.93828*width, y: 0.53798*height), control2: CGPoint(x: 1.01715*width, y: 0.62481*height))
        path.addCurve(to: CGPoint(x: 0.77703*width, y: 0.95433*height), control1: CGPoint(x: 0.97539*width, y: 0.82028*height), control2: CGPoint(x: 0.884*width, y: 0.90545*height))
        path.addCurve(to: CGPoint(x: 0.44092*width, y: 0.97458*height), control1: CGPoint(x: 0.6762*width, y: 1.00041*height), control2: CGPoint(x: 0.55604*width, y: 0.97232*height))
        path.addCurve(to: CGPoint(x: 0.09303*width, y: 0.96776*height), control1: CGPoint(x: 0.32205*width, y: 0.97691*height), control2: CGPoint(x: 0.18022*width, y: 1.03476*height))
        path.addCurve(to: CGPoint(x: 0.05197*width, y: 0.67569*height), control1: CGPoint(x: 0.00413*width, y: 0.89944*height), control2: CGPoint(x: 0.0684*width, y: 0.77524*height))
        path.addCurve(to: CGPoint(x: 0.00832*width, y: 0.45447*height), control1: CGPoint(x: 0.03945*width, y: 0.5998*height), control2: CGPoint(x: 0.00796*width, y: 0.53106*height))
        path.addCurve(to: CGPoint(x: 0.05454*width, y: 0.13024*height), control1: CGPoint(x: 0.00884*width, y: 0.34291*height), control2: CGPoint(x: -0.02961*width, y: 0.21731*height))
        path.addCurve(to: CGPoint(x: 0.44092*width, y: 0.00682*height), control1: CGPoint(x: 0.14299*width, y: 0.03871*height), control2: CGPoint(x: 0.30342*width, y: -0.02084*height))
        path.closeSubpath()
        return path
    }
}


#Preview {
    ZStack {
        Color.red
        CustomBlob()
            .frame(width: 300, height: 300)
    }
}
