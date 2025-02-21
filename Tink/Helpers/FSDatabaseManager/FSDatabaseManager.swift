//
//  FSDatabaseManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FirebaseFirestore
import Combine
import FirebaseStorage
import Cloudinary

@MainActor
@Observable
class FSDatabaseManager: ObservableObject {
    
    var categories: [FSCategory] = []
    var loading: Bool = false
    var goCompleteProfile = false
    var skillsSaved: [Skill] = []
    var allSkillsSaved: [Skill] = []
    
       
    // MARK: - CAROUSEL CONTROLLER
    var currentIndex: Int = 0
    
    /// Fetch categories
    func fetchCategories() async {
        loading = true
        defer { loading = false }

        if self.categories.isEmpty {
            let db = Firestore.firestore()
            let query = db.collection("categories")
            do {
                let snapshot = try await query.getDocuments()
                self.categories = snapshot.documents.compactMap { document in
                    try? document.data(as: FSCategory.self)
                }
            } catch {
                print("Error al obtener categorías: \(error.localizedDescription)")
            }
        }
    }
    
    /// Check if user exists in database
    func checkIfUserExistInDatabase() async throws {
        loading = true
        guard let user = Auth.auth().currentUser else {
            print("No user authenticated")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        do {
            let snapshot = try await userRef.getDocument()
            
            if snapshot.exists {
                if let userData = snapshot.data(),
                   let name = userData["name"] as? String,
                   let email = userData["email"] as? String,
                   let community = userData["community"] as? String,
                   let province = userData["province"] as? String,
                   let locality = userData["locality"] as? String,
                   !community.isEmpty {
                    
                    goCompleteProfile = false
                    
                    // ⚡ Hacemos `imageUrl` opcional
                    let imageUrl = userData["profileImageURL"] as? String ?? nil
                    
                    // Store user in UserDefaults if not already saved
                    if UserDefaults.standard.userSaved == nil {
                        UserDefaults.standard.userSaved = User(
                            id: user.uid,
                            name: name,
                            email: email,
                            community: community,
                            province: province,
                            locality: locality,
                            profileImageURL: imageUrl // ✅ Se asigna solo si existe
                        )
                    }
                    print("✅ User has a valid profile")
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        goCompleteProfile = true
                        print("⚠️ User needs to complete required profile fields")
                    }
                }
                           
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    goCompleteProfile = true
                }
            }
        } catch {
            print("❌ Firestore error: \(error.localizedDescription)")
        }
        loading = false
    }
    
    /// Create new user
    func createNewUser(name: String, surname: String, community: String, province: String, locality: String) async throws {
        loading = true
        defer { loading = false }
        guard let user = Auth.auth().currentUser else {
            print("No user authenticated")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        do {
            let snapshot = try await userRef.getDocument()
            let userData: [String: String] = [
                "name": "\(name) \(surname)",
                "community": community,
                "province": province,
                "locality": locality
            ]
            if snapshot.exists {
                // ✅ User exist, we update it
                try await userRef.updateData(userData)
                
                UserDefaults.standard.userSaved = User(
                    id: user.uid,
                    name: "\(name) \(surname)",
                    email: user.email ?? "",
                    community: community,
                    province: province ,
                    locality: locality
                )
                print("✅ Usuario actualizado en Firestore")
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.goCompleteProfile = false
                }
            } else {
                // ❌ User dont exist, we create it
                var newUser = userData
                newUser["id"] = user.uid
                newUser["email"] = user.email ?? ""
                
                try await userRef.setData(newUser)
                UserDefaults.standard.userSaved = User(
                    id: user.uid,
                    name: "\(name) \(surname)",
                    email: user.email ?? "",
                    community: community,
                    province: province ,
                    locality: locality
                )
                print("✅ Usuario creado en Firestore")
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.goCompleteProfile = false
                }
            }
        } catch {
            print("❌ Firestore error: \(error.localizedDescription)")
        }
    }
    
    /// Function to create new skills
    func createNewSkill(skillName: String, skillDescription: String, skillPrice: String, category: FSCategory, isOnline: Bool? = nil, newSkillPrince: NewSkillPrice) async throws {
        
        // 0. Control loading state
        loading = true
        
        defer {
            loading = false
        }
        
        // 1. No user auth
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        
        // 2. Missing fields
        guard  !skillName.isEmpty, !skillDescription.isEmpty, !skillPrice.isEmpty else {
            return
        }
        
        var newSkill = Skill(
            id: "",
            name: skillName,
            description: skillDescription,
            price: "\(skillPrice) \(newSkillPrince.description)",
            category: category,
            user: user,
            is_online: isOnline
        )
        
        // 3. Reference skills collection
        let db = Firestore.firestore()
        let skillRef = db.collection("skills").document()
        
        do {
            newSkill.id = skillRef.documentID
            try skillRef.setData(from: newSkill) { error in
                if let error = error {
                    print("Error saving skill: \(error.localizedDescription)")
                } else {
                    
                    self.skillsSaved.append(newSkill)
                    self.allSkillsSaved.append(newSkill)
                    print("✅ New skill added to Firestore with ID: \(newSkill.id)")
                }
            }
            currentIndex = 0
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error adding skill to Firestore: \(error.localizedDescription)"])
        }
    }
    
    /// Function to sync skills
    func syncSkills() async throws {
        loading = true
        defer { loading = false }
        guard let userSaved = UserDefaults.standard.userSaved else {
            print("No hay usuario guardado")
            return
        }
        self.skillsSaved = []
        self.allSkillsSaved = []
        let db = Firestore.firestore()
        let query = db.collection("skills")
        do {
            let snapshot = try await query.getDocuments()
            let allSkills = snapshot.documents.compactMap { document in
                try? document.data(as: Skill.self)
            }
            
            // 1. Saved every skill with no filter
            self.allSkillsSaved = allSkills
            
            // 2. Filter skills if user.id == userSaved.id
            self.skillsSaved = allSkills.filter { $0.user.id == userSaved.id }
            print("✅ Correctly sync skills")
        } catch {
            print("Erorr loading categories", error)
        }
    }
    
    /// Update Skill
    func updateSkill(skill: Skill) async throws {
        loading = true
        defer {
            loading = false
        }
        
        // 1. No user auth
        guard let _ = UserDefaults.standard.userSaved else {
            return
        }
        
        // 2. Reference to skill document based on ID
        let db = Firestore.firestore()
        let skillRef = db.collection("skills").document(skill.id)
        
        do {
            self.skillsSaved = []
            self.allSkillsSaved = []
            let encodedSkill = try Firestore.Encoder().encode(skill)
            await MainActor.run {
                skillRef.updateData(encodedSkill)
            }
            currentIndex = 0
            print("✅ Skill updated in Firestore: \(skill.id)")
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Error updating skill in Firestore: \(error.localizedDescription)"
            ])
        }
    }
    
    /// Delete skill func
    func deleteSkill(skill: Skill) async throws {
        // 1. Manage loading
        loading = true
        defer {
            loading = false
        }
        
        guard let _ = UserDefaults.standard.userSaved else {
            return
        }
        
        // 2. Retreive selected skill document
        let db = Firestore.firestore()
        let skillRef = db.collection("skills").document(skill.id)
        
        do {
            // 🔹 Eliminar el documento de Firestore
            try await skillRef.delete()
            
            // 3. Eliminar localmente en UserDefaults (en hilo principal)
            if let index = self.skillsSaved.firstIndex(where: { $0.id == skill.id }) {
                self.skillsSaved.remove(at: index)
            }
            
            currentIndex = 0
            print("🗑️ Skill deleted from Firestore: \(skill.id)")
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Error deleting skill in Firestore: \(error.localizedDescription)"
            ])
        }
    }
    
    /// Delete account
    func deleteAccount() async throws {
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        let firestore = Firestore.firestore()
        
         do {
             // 1. Remove user from users
             try await firestore.collection("users").document(user.id).delete()
             
             // 2. Remove skills where user.id == user.id
             let skillsQuery = try await firestore.collection("skills")
                 .whereField("user.id", isEqualTo: user.id)
                 .getDocuments()
             
             for document in skillsQuery.documents {
                 try await firestore.collection("skills").document(document.documentID).delete()
             }
             
             print("Skills and account deleted")
         } catch {
             print("Error deleting account: \(error.localizedDescription)")
             throw error
         }
     
    }
    
    /// Update name
    func updateName(name: String) async throws {
        loading = true
        defer {
            loading = false
        }
        guard let user = UserDefaults.standard.userSaved else {
            return
        }
        // Database
        let db = Firestore.firestore()
        
        let userReference = db.collection("users").document(user.id)
        // Update name in database
        do {
            // Wait 2 seconds
            try await Task.sleep(nanoseconds: 2_000_000_000)
            // Get skills where user.id == user.id
            let skillsQuerySnapshot = try await db.collection("skills")
                .whereField("user.id", isEqualTo: user.id)
                .getDocuments()
            
            await MainActor.run {
                // Modify name in "Users" collection
                userReference.updateData(["name": name]) { error in
                    if let error = error {
                        print("Error updating name: \(error.localizedDescription)")
                    } else {
                        UserDefaults.standard.userSaved?.name = name
                        print("✅ Name updated")
                    }
                }
                // Modify user.name in skills collection
                for document in skillsQuerySnapshot.documents {
                    let skillRef = db.collection("skills").document(document.documentID)
                    skillRef.updateData(["user.name": name]) { error in
                        if let error = error {
                            print("Error updating name in skill \(document.documentID): \(error.localizedDescription)")
                        } else {
                            print("✅ Name updated in skill \(document.documentID)")
                        }
                    }
                }
            }
        } catch {
            print("Error updating name: \(error.localizedDescription)")
        }
    }
}

// MARK: - IMAGE MANAGEMENT
extension FSDatabaseManager {
    
    func uploadUserDefaultsUserImage(imageURL: String) async throws {
        guard var userSaved = UserDefaults.standard.userSaved else {
            print("No hay usuario guardado")
            return
        }
        
        userSaved.profileImageURL = imageURL
        UserDefaults.standard.userSaved = userSaved
    }
    
    func updateFirestoreImage(imageURL: String) async throws {
        guard let user = UserDefaults.standard.userSaved else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se encontró el usuario en UserDefaults."])
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
        
        // Crear un objeto usuario con el campo actualizado (con el imageURL)
        var updatedUser = user  // Asumiendo que 'user' es un objeto tipo User
        updatedUser.profileImageURL = imageURL  // Aquí se actualiza el URL de la imagen
        
        // Codificar el objeto usuario usando Firestore.Encoder()
        let encodedUser = try Firestore.Encoder().encode(updatedUser)
        
        do {
            // Usamos setData para actualizar el documento con la codificación
            try await userRef.setData(encodedUser, merge: true)  // merge: true para evitar sobreescribir otros campos
            print("Imagen de usuario actualizada exitosamente")
        } catch {
            print("Error al actualizar la imagen del usuario: \(error.localizedDescription)")
            throw error  // Lanzar el error para manejarlo en el llamador
        }
    }
    
    /// Update skills
    func updateFirestoreImageSkill(imageURL: String) async throws {
        guard let user = UserDefaults.standard.userSaved else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se encontró el usuario en UserDefaults."])
        }
        let db = Firestore.firestore()
        do {
            let skillsQuerySnapshot = try await db.collection("skills")
                .whereField("user.id", isEqualTo: user.id)
                .getDocuments()
            
            for document in skillsQuerySnapshot.documents {
                let skillRef = db.collection("skills").document(document.documentID)
                
                await MainActor.run {
                    skillRef.updateData(["user.profileImageURL": imageURL]) { error in
                        if let error = error {
                            print("❌ Error al actualizar imagen en skill \(document.documentID): \(error.localizedDescription)")
                        } else {
                            print("✅ Imagen actualizada en skill \(document.documentID)")
                        }
                    }
                }
            }
        } catch {
            print("Erro updating skills")
        }
    }
    
    

}

// MOCK FOR PREVIEWS
final class FSDatabaseManagerMock: FSDatabaseManager {
    
    override init() {
        super.init()
        self.categories = [
            FSCategory(id: "1", name: "Albañilería", is_manual: true),
            FSCategory(id: "2", name: "Carpintería", is_manual: true),
            FSCategory(id: "3", name: "Clases online", is_manual: false),
        ]
    }
}
