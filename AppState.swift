import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var appPhase: AppPhase = .splash
    @Published var currentUser: UserProfile?
    @Published var hasCompletedOnboarding: Bool = false
    
    let achievementManager = AchievementManager()
    let healthKit = HealthKitService.shared
    
    init() {
        loadPersistedData()
    }
    
    func loadPersistedData() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUser = user
            self.hasCompletedOnboarding = true
            self.appPhase = .main
            
            // Request HealthKit on app launch if previously authorized
            Task { await healthKit.requestAuthorization() }
        }
    }
    
    func saveUser(_ user: UserProfile) {
        self.currentUser = user
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
        hasCompletedOnboarding = true
    }
    
    func checkAchievements() {
        guard let user = currentUser else { return }
        if let data = UserDefaults.standard.data(forKey: "trainingSessions"),
           let sessions = try? JSONDecoder().decode([TrainingSession].self, from: data) {
            achievementManager.checkAndUnlock(user: user, sessions: sessions)
        }
    }
    
    func resetSession() {
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "trainingSessions")
        UserDefaults.standard.removeObject(forKey: "achievements")
        UserDefaults.standard.removeObject(forKey: "trickLog")
        UserDefaults.standard.removeObject(forKey: "currentStreak")
        UserDefaults.standard.removeObject(forKey: "longestStreak")
        UserDefaults.standard.removeObject(forKey: "lastSessionDate")
        currentUser = nil
        hasCompletedOnboarding = false
        achievementManager.reset()
        TrickLogService.shared.reset()
        appPhase = .splash
    }
    
    enum AppPhase {
        case splash, onboarding, welcome, main
    }
}
