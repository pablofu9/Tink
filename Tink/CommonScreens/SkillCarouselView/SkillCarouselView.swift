//
//  SkillCarouselView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 13/2/25.
//

import SwiftUI

struct SkillCarouselView: View {
    
    var skills: [Skill]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Carrusel con paginación
            TabView(selection: $selectedIndex) {
                ForEach(skills.indices, id: \.self) { index in
                    SkillCardView(skill: skills[index])
                        .tag(index)
                        .id(skills[index].id) 
                       
                }
            }
            
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Index pagination
            HStack {
                ForEach(0..<skills.count, id: \.self) { index in
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
    SkillCarouselView(skills: Skill.sampleArray, selectedIndex: $selectedIndex)
}
