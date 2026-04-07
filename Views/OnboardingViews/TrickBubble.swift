//
//  TrickBubble.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct TrickBubble: View {
    let trick: SkateTrick
    let isRemoving: Bool
    let onTap: () -> Void
    
    var difficultyColor: Color {
        switch trick.difficulty {
        case .beginner: return Color(hex: "#4CAF50")
        case .intermediate: return Color(hex: "#2196F3")
        case .advanced: return Color(hex: "#FF9800")
        case .expert: return Color(hex: "#F44336")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(trick.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(trick.difficulty.localizedName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(difficultyColor)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(difficultyColor.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isRemoving ? 0.1 : 1.0)
        .opacity(isRemoving ? 0 : 1)
        .rotationEffect(isRemoving ? .degrees(180) : .degrees(0))
    }
}
