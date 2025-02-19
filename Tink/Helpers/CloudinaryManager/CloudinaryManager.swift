//
//  CloudinaryManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 19/2/25.
//

import Foundation
import SwiftUI
import Cloudinary

class CloudinaryManager {
    static let shared = CloudinaryManager()
    
    private var cloudinary: CLDCloudinary

    init() {
        // Configura tu Cloudinary con el 'cloud_name' de tu cuenta
        let config = CLDConfiguration(cloudName: "dbzimmpcy", apiKey: "531992821563818", apiSecret: "FExZYcPWT6-aqyxYDtGGGkQrtP0")
        cloudinary = CLDCloudinary(configuration: config)
        print("Cloudinary configured")
    }
    
    // Método para subir la imagen con el userId como nombre
    func uploadImage(image: UIImage) async -> String? {
           guard let user = UserDefaults.standard.userSaved else {
               print("Error: No se encontró el usuario en UserDefaults.")
               return nil
           }
           
           guard let imageData = image.jpegData(compressionQuality: 0.75) else {
               print("Error: No se pudo convertir la imagen a datos.")
               return nil
           }
           
           // Define el public_id basado en el userId
           let publicId = "user_\(user.id)"  // Esto será el nombre único para la imagen en Cloudinary
           
           deleteImage(publicId: publicId)
        
           let params = CLDUploadRequestParams()
           params.setPublicId(publicId)

           // Convertir el bloque de finalización en un async await con checked continuation
           return await withCheckedContinuation { continuation in
               cloudinary.createUploader().upload(data: imageData, uploadPreset: "profile_image", params: params, completionHandler:  { response, error in
                   if let error = error {
                       print("Error al subir imagen: \(error.localizedDescription)")
                       continuation.resume(returning: nil)
                   } else if let response = response {
                       print("Imagen subida con éxito: \(response.secureUrl ?? "Sin URL")")
                       continuation.resume(returning: response.secureUrl)
                   }
               })
           }
       
    }
    
    func deleteImage(publicId: String) {
        cloudinary.createManagementApi().destroy(publicId) { (response, error) in
               if let error = error {
                   print("Error al eliminar la imagen: \(error.localizedDescription)")
               } else if let response = response {
                   print("Resultado de eliminación: \(response.result ?? "Sin respuesta")")
               }
           }
    }
    
    
}
