//
//  OnboardingStep2.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI

struct OnboardingStep2: View {
    @Binding var selectedLevel: SkaterLevel?
    var onNext: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Level")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("How experienced are you on a board?")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .padding(.horizontal, 32)
                
                VStack(spacing: 12) {
                    ForEach(SkaterLevel.allCases, id: \.self) { level in
                        LevelCard(
                            level: level,
                            isSelected: selectedLevel == level,
                            onTap: { selectedLevel = level }
                        )
                    }
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    SecondaryButton(title: "Back")
                }
                
                Button(action: onNext) {
                    PrimaryButton(title: "Next", isEnabled: selectedLevel != nil)
                }
                .disabled(selectedLevel == nil)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}
