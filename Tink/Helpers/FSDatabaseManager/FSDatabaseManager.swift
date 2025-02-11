//
//  FSDatabaseManager.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 11/2/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
class FSDatabaseManager: ObservableObject {
    
    @Published var categories: [FSCategory] = []
    @Published var loading: Bool = false
    
    func fetchCategories() async {
        let db = Firestore.firestore()
        let query = db.collection("categoríes") // Ojo con la tilde en "categories"
        loading = true

        do {
            let snapshot = try await query.getDocuments()
            self.categories = snapshot.documents.compactMap { document in
                try? document.data(as: FSCategory.self)
            }
        } catch {
            print("Error al obtener categorías: \(error.localizedDescription)")
        }

        // Asegurar que loading esté activo al menos 5 segundos
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 segundos

        loading = false
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
