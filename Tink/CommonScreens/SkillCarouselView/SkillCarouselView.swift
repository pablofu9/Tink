//
//  SkillCarouselView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI

struct SkillCarouselView: View {
    
    @Binding var skills: [Skill]
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Carrusel con paginación
            TabView(selection: $currentIndex) {
                ForEach(skills.indices, id: \.self) { index in
                    SkillCardView(skill: $skills[index])
                        .tag(index)
                        .id(skills[index].id)
                       
                }
            }
            
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Index pagination
            HStack {
                ForEach(0..<skills.count, id: \.self) { index in
                    if currentIndex == index {
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
            .animation(.easeInOut(duration: 0.3), value: currentIndex) // Animación con duración
        }
        .frame(height: 320)
    }
}

#Preview {
    @Previewable @State var selectedIndex = 0
    let mockManager = FSDatabaseManager()
    
    SkillCarouselView(skills: .constant([]), currentIndex: $selectedIndex)
        .environmentObject(mockManager)
}
