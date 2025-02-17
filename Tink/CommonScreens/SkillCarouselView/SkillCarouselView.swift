//
//  SkillCarouselView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI

struct SkillCarouselView: View {
    
    @Binding var selectedIndex: Int
    @EnvironmentObject var databaseManager: FSDatabaseManager

    var body: some View {
        VStack(spacing: 0) {
            // Carrusel con paginación
            TabView(selection: $selectedIndex) {
                ForEach(databaseManager.filteredSkills.indices, id: \.self) { index in
                    SkillCardView(skill: databaseManager.filteredSkills[index])
                        .tag(index)
                        .id(databaseManager.filteredSkills[index].id)
                       
                }
            }
            
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Index pagination
            HStack {
                ForEach(0..<databaseManager.filteredSkills.count, id: \.self) { index in
                    if selectedIndex == index {
                        Capsule()
                            .frame(width: 20, height: 8)
                            .foregroundStyle(ColorManager.primaryBasicColor)
                            .transition(.scale)
                    } else {
                        Circle()
                            .fill(ColorManager.primaryGrayColor.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .padding(2)
                            .transition(.scale)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedIndex) // Animación con duración
        }
        .frame(height: 320)
    }
}

#Preview {
    @Previewable @State var selectedIndex = 0
    let mockManager = FSDatabaseManager()

    SkillCarouselView(selectedIndex: $selectedIndex)
        .environmentObject(mockManager)
}
