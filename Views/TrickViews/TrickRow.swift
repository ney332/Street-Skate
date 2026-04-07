//
//  TrickRow.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct TrickRow: View {
    let trick: SkateTrick
    let isUnlocked: Bool
    let onUnlock: () -> Void
    @State private var showingUnlock = false
    
    var difficultyColor: Color {
        switch trick.difficulty {
        case .beginner: return Color(hex: "#4CAF50")
        case .intermediate: return Color(hex: "#2196F3")
        case .advanced: return Color(hex: "#FF9800")
        case .expert: return Color(hex: "#F44336")
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Lock/unlock indicator
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("verde").opacity(0.15) : Color.white.opacity(0.05))
                    .frame(width: 44, height: 44)
                Image(systemName: isUnlocked ? "checkmark" : "lock.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? Color("verde") : Color.white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trick.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : Color.white.opacity(0.5))
                HStack(spacing: 8) {
                    Text(trick.category.localizedName)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 3, height: 3)
                    Text(trick.difficulty.localizedName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(difficultyColor)
                }
            }
            
            Spacer()
            
            // XP badge
            VStack(spacing: 2) {
                Text("+\(trick.xpReward)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(isUnlocked ? Color("verde") : Color.white.opacity(0.3))
                Text("XP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isUnlocked ? Color("verde").opacity(0.7) : Color.white.opacity(0.2))
            }
            
            if !isUnlocked {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        showingUnlock = true
                        onUnlock()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { showingUnlock = false }
                }) {
                    Text("Unlock")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(LinearGradient(
                                colors: [Color("verde"), Color("verde")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                        )
                }
                .scaleEffect(showingUnlock ? 0.9 : 1.0)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isUnlocked ? 0.05 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isUnlocked ? Color("verde").opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
