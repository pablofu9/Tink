//
//  CameraManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 19/2/25.
//

import Foundation
import SwiftUI
import AVFoundation
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

@MainActor
@Observable
class CameraManager: NSObject, ObservableObject {
    
    var selectedImage: UIImage?
    var croppedImage: UIImage?
    var showImagePicker = false
    var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    
    /// Check camera permission
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted:
            completion(false)
        case .denied:
            completion(false)
        case .authorized:
            completion(true)
        default :
            completion(false)
        }
    }
    
    /// Check photo library permission
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
          let status = PHPhotoLibrary.authorizationStatus()
          switch status {
          case .authorized, .limited:
              completion(true)
          case .notDetermined:
              PHPhotoLibrary.requestAuthorization { newStatus in
                  DispatchQueue.main.async {
                      completion(newStatus == .authorized || newStatus == .limited)
                  }
              }
          default:
              completion(false)
          }
      }
}
