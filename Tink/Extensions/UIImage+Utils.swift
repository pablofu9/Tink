//
//  UIImage+Utils.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 19/2/25.
//
import Foundation
import SwiftUI

/// Extension to fix orientation of an UIImage without EXIF
public extension UIImage {
    func fixOrientation(og: UIImage) -> UIImage {
        
        switch og.imageOrientation {
        case .up:
            return self
        case .down:
            return UIImage(cgImage: cgImage!, scale: scale, orientation: .down)
        case .left:
            return UIImage(cgImage: cgImage!, scale: scale, orientation: .left)
        case .right:
            return UIImage(cgImage: cgImage!, scale: scale, orientation: .right)
        case .upMirrored:
            return self
        case .downMirrored:
            return self
        case .leftMirrored:
            return self
        case .rightMirrored:
            return self
        @unknown default:
            return self
        }
    }
}
