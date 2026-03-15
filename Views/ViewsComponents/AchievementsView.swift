//
//  AchievementsView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var manager = AchievementManager()
    @Environment(\.dismiss) var dismiss
    
    var unlocked: [Achievement] {
        let list: [Achievement] = manager.achievements.filter { $0.isUnlocked }
        return list
    }
    
    var locked: [Achievement] {
        let list: [Achievement] = manager.achievements.filter { !$0.isUnlocked }
        return list
    }
    
    private var unlockedCount: Int { unlocked.count }
    private var lockedCount: Int { locked.count }
    private var completionPercent: Int {
        let total = manager.achievements.count
        guard total > 0 else { return 0 }
        let percent = (Double(unlockedCount) / Double(total)) * 100.0
        return Int(percent.rounded())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header stats
                        HStack(spacing: 0) {
                            AchievStat(value: "\(unlockedCount)", label: "Unlocked", color: Color(hex: "#FFD700"))
                            Divider().background(Color.white.opacity(0.1)).frame(height: 40)
                            AchievStat(value: "\(lockedCount)", label: "Remaining", color: Color.white.opacity(0.4))
                            Divider().background(Color.white.opacity(0.1)).frame(height: 40)
                            AchievStat(
                                value: "\(completionPercent)%",
                                label: "Complete",
                                color: Color(hex: "#4CAF50")
                            )
                        }
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        
                        // Unlocked section
                        if !unlocked.isEmpty {
                            AchievSection(title: "🏆 Unlocked", achievements: unlocked)
                        }
                        
                        // Locked section
                        AchievSection(title: "🔒 In Progress", achievements: locked)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 8)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "#FFD700"))
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let user = appState.currentUser {
                if let data = UserDefaults.standard.data(forKey: "trainingSessions"),
                   let sessions = try? JSONDecoder().decode([TrainingSession].self, from: data) {
                    manager.checkAndUnlock(user: user, sessions: sessions)
                }
            }
        }
    }
}

struct AchievSection: View {
    let title: String
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(achievements) { a in
                    AchievCard(achievement: a)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct AchievCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color(hex: "#FFD700").opacity(0.15) : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isUnlocked ? Color(hex: "#FFD700") : Color.white.opacity(0.2))
                
                if achievement.isUnlocked {
                    Circle()
                        .stroke(Color(hex: "#FFD700").opacity(0.4), lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }
            
            VStack(spacing: 3) {
                Text(achievement.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? .white : Color.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if achievement.xpReward > 0 {
                Text("+\(achievement.xpReward) XP")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? Color(hex: "#FFD700") : Color.white.opacity(0.2))
            }
            
            if let date = achievement.unlockedAt {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.25))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.isUnlocked ? Color.white.opacity(0.07) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(achievement.isUnlocked ? Color(hex: "#FFD700").opacity(0.25) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

struct AchievStat: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievement Toast overlay
struct AchievementToast: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFD700").opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: achievement.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Achievement Unlocked!")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#FFD700"))
                        .tracking(0.5)
                    Text(achievement.title)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                    Text(achievement.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                
                Spacer()
                
                Button(action: { withAnimation { isShowing = false } }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#FFD700").opacity(0.35), lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: "#FFD700").opacity(0.2), radius: 16, y: 4)
            )
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(.top, 60)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
