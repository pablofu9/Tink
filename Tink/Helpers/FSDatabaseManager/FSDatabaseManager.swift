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

@MainActor
class FSDatabaseManager: ObservableObject {
    
    @Published var categories: [FSCategory] = []
    @Published var loading: Bool = false
    @Published var goCompleteProfile = false
    
    func fetchCategories() async {
        categories = []
        let db = Firestore.firestore()
        let query = db.collection("categories")
        loading = true
        // Delay to pretend loading
       // try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            let snapshot = try await query.getDocuments()
            self.categories = snapshot.documents.compactMap { document in
                try? document.data(as: FSCategory.self)
            }
        } catch {
            print("Error al obtener categorías: \(error.localizedDescription)")
        }
        loading = false
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
                    
                    UserDefaults.standard.skillsSaved.append(newSkill)
                    print("✅ New skill added to Firestore with ID: \(newSkill.id)")
                }
            }
        } catch {
            throw NSError(domain: "FirestoreError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error adding skill to Firestore: \(error.localizedDescription)"])
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
