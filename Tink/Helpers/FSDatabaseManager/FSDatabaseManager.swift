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
    
}

// MARK: - USER MANAGEMENT
extension FSDatabaseManager {
    
    /// Function to check if user already exists
    func handleUserInFirestore() {
        loading = true
        defer { loading = false }
        // 1. Check if user is authenticated
        guard let user = Auth.auth().currentUser else {
            print("No user authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { document, error in
            // 3. User doesn't exist, create it
            let name = (user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? user.displayName!
            : user.email?.components(separatedBy: "@").first ?? ""
            
            var saveUser = User(id: user.uid, name: name, email: user.email ?? "", profileImageURL: "")
            
            if let document = document, document.exists {
                print("User already exists in firestore. - Do nothing")
                if let data = document.data(),
                   let profileImageURL = data["profileImageURL"] as? String {
                    saveUser.profileImageURL = profileImageURL
                }
            } else {
                do {
                    let encodedUser = try Firestore.Encoder().encode(saveUser)
                    
                    // 4. Save user in Firestore
                    userRef.setData(encodedUser, merge: true) { error in
                        if let error = error {
                            print("Error saving user in firestore: \(error.localizedDescription)")
                        } else {
                            print("User saved in firestore correctly.")
                            
                        }
                    }
                } catch {
                    print("Codification Error: \(error.localizedDescription)")
                }
            }
            UserDefaults.standard.userSaved = saveUser
        }
    }
    
    func getUser(userID: String) async throws -> User? {
        let firestore = Firestore.firestore()
            
            do {
                // Obtener el documento del usuario usando su ID
                let document = try await firestore.collection("users").document(userID).getDocument()
                
                // Verificar si el documento existe
                guard document.exists else {
                    print("User not found")
                    return nil
                }
                
                // Decodificar el documento en un objeto User
                let user = try document.data(as: User.self)
                return user
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
                throw error
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
    
    /// Deletes all chats that contain a specific user ID in the `users` array field within the Firestore `chats` collection.
    ///
    /// - Throws: An error if there is any issue while fetching the documents or deleting them from Firestore.
    ///
    /// This method does the following:
    /// 1. Queries the Firestore `chats` collection for all documents where the `users` array contains the given `userId`.
    /// 2. If no matching chats are found, it prints a message and exits early.
    /// 3. For each document in the query result, the method deletes the document from Firestore.
    /// 4. It handles loading state and error handling for the operation.
    func deleteChats() async throws {
        // Set the loading state to true before starting the process and false when done
        loading = true
        defer { loading = false }

        // Check if there is a saved user in UserDefaults
        guard let user = UserDefaults.standard.userSaved else {
            return  // Exit early if no user is found
        }
        let db = Firestore.firestore()
        do {
            // Query Firestore for chats where the userId exists in the "users" array
            let querySnapshot = try await db.collection("chats")
                .whereField("users", arrayContains: user.id) // Query for chats containing the userId in the "users" array
                .getDocuments()

            // Check if the query found any matching chat documents
            guard !querySnapshot.documents.isEmpty else {
                print("No chats found for userId \(user.id)") // Inform the user if no chats were found
                return
            }

            // Loop through each document (chat) that matches the query
            for document in querySnapshot.documents {
                // Delete the chat document from Firestore
                try await document.reference.delete()  // Deletes the document from Firestore
                print("Deleted chat with ID: \(document.documentID)") // Log the deleted chat's document ID
            }

        } catch {
            // If an error occurs, log the error message and re-throw the error
            print("Error deleting chats: \(error.localizedDescription)")
            throw error  // Propagate the error for further handling
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
