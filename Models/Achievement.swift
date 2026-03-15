//
//  Achievement.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let requirement: AchievementRequirement
    var unlockedAt: Date? = nil
    
    var isUnlocked: Bool { unlockedAt != nil }
}

enum AchievementRequirement: Codable {
    case sessionsCount(Int)
    case totalDistanceKm(Double)
    case totalCalories(Double)
    case tricksUnlocked(Int)
    case totalXP(Int)
    case pushCount(Int)
    case singleSessionDistance(Double)
    case singleSessionDuration(TimeInterval)
}

// MARK: - All Achievements
extension Achievement {
    static let all: [Achievement] = [
        // Sessions
        Achievement(id: "first_session", title: "First Push", description: "Complete your first skate session", icon: "flag.fill", xpReward: 100, requirement: .sessionsCount(1)),
        Achievement(id: "sessions_5", title: "Getting Serious", description: "Complete 5 sessions", icon: "flame.fill", xpReward: 200, requirement: .sessionsCount(5)),
        Achievement(id: "sessions_20", title: "Dedicated Skater", description: "Complete 20 sessions", icon: "star.fill", xpReward: 500, requirement: .sessionsCount(20)),
        Achievement(id: "sessions_50", title: "Street Legend", description: "Complete 50 sessions", icon: "crown.fill", xpReward: 1000, requirement: .sessionsCount(50)),
        
        // Distance
        Achievement(id: "dist_1km", title: "First Kilometer", description: "Skate a total of 1 km", icon: "location.fill", xpReward: 50, requirement: .totalDistanceKm(1)),
        Achievement(id: "dist_10km", title: "City Explorer", description: "Skate a total of 10 km", icon: "map.fill", xpReward: 150, requirement: .totalDistanceKm(10)),
        Achievement(id: "dist_50km", title: "Road Warrior", description: "Skate a total of 50 km", icon: "road.lanes", xpReward: 400, requirement: .totalDistanceKm(50)),
        Achievement(id: "dist_100km", title: "Century Rider", description: "Skate a total of 100 km", icon: "trophy.fill", xpReward: 1000, requirement: .totalDistanceKm(100)),
        
        // Tricks
        Achievement(id: "tricks_5", title: "Learning the Basics", description: "Unlock 5 tricks", icon: "skateboard", xpReward: 100, requirement: .tricksUnlocked(5)),
        Achievement(id: "tricks_10", title: "Trick Collector", description: "Unlock 10 tricks", icon: "star.circle.fill", xpReward: 250, requirement: .tricksUnlocked(10)),
        Achievement(id: "tricks_20", title: "Trick Master", description: "Unlock 20 tricks", icon: "crown.fill", xpReward: 600, requirement: .tricksUnlocked(20)),
        
        // Single session
        Achievement(id: "session_5km", title: "Long Haul", description: "Skate 5 km in a single session", icon: "arrow.right.to.line", xpReward: 300, requirement: .singleSessionDistance(5)),
        Achievement(id: "session_1hr", title: "Hour Power", description: "Skate for 1 hour straight", icon: "timer", xpReward: 350, requirement: .singleSessionDuration(3600)),
        
        // Calories
        Achievement(id: "cal_1000", title: "Calorie Crusher", description: "Burn 1,000 calories total", icon: "flame.circle.fill", xpReward: 200, requirement: .totalCalories(1000)),
        Achievement(id: "cal_5000", title: "Fitness Fanatic", description: "Burn 5,000 calories total", icon: "bolt.heart.fill", xpReward: 500, requirement: .totalCalories(5000)),
        
        // XP
        Achievement(id: "xp_500", title: "XP Grinder", description: "Earn 500 XP", icon: "sparkles", xpReward: 0, requirement: .totalXP(500)),
        Achievement(id: "xp_2000", title: "XP Hunter", description: "Earn 2,000 XP", icon: "sparkle", xpReward: 0, requirement: .totalXP(2000)),
    ]
}

// MARK: - Achievement Manager
class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var newlyUnlocked: Achievement? = nil
    
    init() { loadAchievements() }
    
    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge saved unlock dates with full list
            achievements = Achievement.all.map { base in
                var a = base
                if let match = saved.first(where: { $0.id == base.id }), match.isUnlocked {
                    a.unlockedAt = match.unlockedAt
                }
                return a
            }
        } else {
            achievements = Achievement.all
        }
    }
    
    func checkAndUnlock(user: UserProfile, sessions: [TrainingSession]) {
        var changed = false
        
        for i in 0..<achievements.count {
            guard !achievements[i].isUnlocked else { continue }
            
            let shouldUnlock: Bool
            switch achievements[i].requirement {
            case .sessionsCount(let n):
                shouldUnlock = user.totalSessions >= n
            case .totalDistanceKm(let km):
                shouldUnlock = user.totalDistanceKm >= km
            case .totalCalories(let cal):
                shouldUnlock = user.totalCalories >= cal
            case .tricksUnlocked(let n):
                shouldUnlock = user.unlockedTricks.count >= n
            case .totalXP(let xp):
                shouldUnlock = user.xp >= xp
            case .pushCount(let n):
                shouldUnlock = sessions.reduce(0) { $0 + $1.pushCount } >= n
            case .singleSessionDistance(let km):
                shouldUnlock = sessions.contains { $0.distanceKm >= km }
            case .singleSessionDuration(let secs):
                shouldUnlock = sessions.contains { $0.duration >= secs }
            }
            
            if shouldUnlock {
                achievements[i].unlockedAt = Date()
                newlyUnlocked = achievements[i]
                changed = true
            }
        }
        
        if changed { save() }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "achievements")
        }
    }
    
    func reset() {
        achievements = Achievement.all
        UserDefaults.standard.removeObject(forKey: "achievements")
    }
}
