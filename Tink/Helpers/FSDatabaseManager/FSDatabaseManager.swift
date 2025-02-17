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

@MainActor
@Observable
class FSDatabaseManager: ObservableObject {
    
    var categories: [FSCategory] = []
    var loading: Bool = false
    var goCompleteProfile = false
    var skillsSaved: [Skill] = []
    var allSkillsSaved: [Skill] = []
    
    var filteredSkills: [Skill] {
        let userId = UserDefaults.standard.userSaved?.id
        return skillsSaved.filter { $0.user.id == userId }
    }
   
    // MARK: - CAROUSEL CONTROLLER
     var currentIndex: Int = 0
    
    func fetchCategories() async {
        loading = true
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
                   let surname = userData["surname"] as? String,
                   let name = userData["name"] as? String,
                   let email = userData["email"] as? String,
                   let community = userData["community"] as? String,
                   let province = userData["province"] as? String,
                   let locality = userData["locality"] as? String,
                   !surname.isEmpty {
                    goCompleteProfile = false
                    
                    // Store userdefault usersaved data
                    if UserDefaults.standard.userSaved == nil {
                        UserDefaults.standard.userSaved = User(
                            id: user.uid,
                            name: name,
                            email: email,
                            surname: surname,
                            community: community,
                            province: province ,
                            locality: locality
                        )
                    }
                    print("✅ User has a valid DNI")
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        goCompleteProfile = true
                        print("⚠️ User needs to complete DNI")
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
    
    func createNewUser(name: String, surname: String, community: String, province: String, locality: String) async throws {
        loading = true
        guard let user = Auth.auth().currentUser else {
            print("No user authenticated")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        do {
            let snapshot = try await userRef.getDocument()
            let userData: [String: String] = [
                "name": name,
                "surname": surname,
                "community": community,
                "province": province,
                "locality": locality
            ]
            if snapshot.exists {
                // ✅ User exist, we update it
                try await userRef.updateData(userData)
                
                UserDefaults.standard.userSaved = User(
                    id: user.uid,
                    name: name,
                    email: user.email ?? "",
                    surname: surname,
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
                    name: name,
                    email: user.email ?? "",
                    surname: surname,
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
        loading = false
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
            // 🔹 Codificar el objeto Skill en un diccionario seguro
            let encodedSkill = try Firestore.Encoder().encode(skill)
            print(skill)
            // 🔹 Actualizar Firestore con el objeto completo
            try await skillRef.setData(encodedSkill, merge: true)

            // 3. Actualizar localmente en UserDefaults (en hilo principal)
            if let index = self.skillsSaved.firstIndex(where: { $0.id == skill.id }) {
                self.skillsSaved[index] = skill
            }
            
            if let allIndex = self.allSkillsSaved.firstIndex(where: { $0.id == skill.id}) {
                self.allSkillsSaved[allIndex] = skill
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
