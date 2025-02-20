//
//  CropView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 19/2/25.
//

import Foundation
import SwiftUI

struct CropImageView: View {
    var uiImage: UIImage
    var save: (UIImage?) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var offsetLimit: CGSize = .zero
    @State private var offset = CGSize.zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var imageViewSize: CGSize = .zero
    @State private var croppedImage: UIImage?
    let mask = CGSize(width: 200, height: 200)
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged { gesture in
                offsetLimit = getOffsetLimit()
                
                let width = min(
                    max(-offsetLimit.width, lastOffset.width + gesture.translation.width),
                    offsetLimit.width
                )
                let height = min(
                    max(-offsetLimit.height, lastOffset.height + gesture.translation.height),
                    offsetLimit.height
                )
                
                offset = CGSize(width: width, height: height)
            }
            .onEnded { value in
                lastOffset = offset
            }
        
        let scaleGesture = MagnifyGesture()
            .onChanged { gesture in
                let scaledValue = (gesture.magnification - 1) * 0.5 + 1
                scale = min(max(scaledValue * lastScale, max(mask.width / imageViewSize.width, mask.height / imageViewSize.height)), 5)
            }
            .onEnded { _ in
                lastScale = scale
                lastOffset = offset
            }
        
        ZStack(alignment: .center) {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        GeometryReader { geometry in
                            Color.clear
                        }
                    }
                    .scaleEffect(scale)
                    .offset(offset)
            }
            .blur(radius: 10)
            
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .mask(
                    Circle()
                        .frame(width: mask.width, height: mask.height)
                )
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: mask.width, height: mask.height)
                }
            BackButton(action: {
                dismiss()
            })
            .frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 20)
            Button(action: {
                croppedImage = cropImage(
                    uiImage,
                    toRect:
                        CGRect(
                            x: (((imageViewSize.width) - (mask.width / scale)) / 2 - offset.width / scale),
                            y: (((imageViewSize.height) - (mask.height / scale)) / 2 - offset.height / scale),
                            width: mask.width / scale,
                            height: mask.height / scale),
                    viewWidth: UIScreen.main.bounds.width,
                    viewHeight: UIScreen.main.bounds.height)
            }) {
                Text("CROP".localized)
                    .foregroundStyle(ColorManager.defaultWhite)
                    .font(.custom(CustomFonts.extraBold, size: 18))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(ColorManager.primaryBasicColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .shadow(color: ColorManager.primaryGrayColor.opacity(0.2), radius: 2, x: 0, y: 2)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .simultaneousGesture(dragGesture)
        .simultaneousGesture(scaleGesture)
        .onChange(of: croppedImage) {
            save(croppedImage)
            dismiss()
        }
        .onAppear {
            let factor = UIScreen.main.bounds.width / uiImage.size.width
            imageViewSize.height = uiImage.size.height * factor
            imageViewSize.width = uiImage.size.width * factor
        }
    }
    
    func getOffsetLimit() -> CGSize {
        var offsetLimit: CGSize = .zero
        offsetLimit.width = ((imageViewSize.width * scale) - mask.width) / 2
        offsetLimit.height = ((imageViewSize.height * scale) - mask.height) / 2
        return offsetLimit
    }
    
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        var cropZone: CGRect
        
        if inputImage.imageOrientation == .right {
            cropZone = CGRect(x: cropRect.origin.y * imageViewScale,
                              y: inputImage.size.width - (cropRect.size.width * imageViewScale) - (cropRect.origin.x * imageViewScale),
                              width: cropRect.size.height * imageViewScale,
                              height: cropRect.size.width * imageViewScale)
        } else if inputImage.imageOrientation == .down {
            cropZone = CGRect(x: inputImage.size.width - (cropRect.origin.x * imageViewScale),
                              y: inputImage.size.height - (cropRect.origin.y * imageViewScale),
                              width: -cropRect.size.width * imageViewScale,
                              height: -cropRect.size.height * imageViewScale)
        } else {
            cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                              y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)
        }
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone) else {
            return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        
        return croppedImage.fixOrientation(og: inputImage)
    }
}


struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImage = UIImage(named: "sampleImage") ?? UIImage(systemName: "photo")!
        
        // Vista previa con una imagen de ejemplo y una acción de recorte
        CropImageView(uiImage: sampleImage) { croppedImage in
            print("Imagen recortada")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}


