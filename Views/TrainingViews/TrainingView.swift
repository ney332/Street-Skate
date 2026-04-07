import SwiftUI
import MapKit

struct TrainingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var trainingVM = TrainingViewModel()
    @StateObject private var streakService = StreakService()
    @State private var showSessionView = false
    @State private var showTrickSelector = false
    @State private var selectedTricksToTrain: Set<String> = []
    @State private var showAllLevels: Bool = false
    
    var user: UserProfile? { appState.currentUser }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Summary".localized)
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Skateboarding for Everyone".localized)
                            .font(.system(size: 15))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    // Start Training Card
                    if let u = user {
                        Button(action: { showAllLevels = true }) {
                            XPLevelCard(user: u)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }
                    
                    // Streak + Calendar
                    VStack(spacing: 12) {
                        StreakCard(streakService: streakService)
                        WeeklyCalendarStrip(sessions: trainingVM.recentSessions)
                    }
                    .padding(.horizontal, 20)
                    
                    // Daily Metrics
                    DailyMetricsSection(trainingVM: trainingVM)
                        .padding(.horizontal, 20)
                    
                    // Recent Sessions
                    RecentSessionsSection(sessions: trainingVM.recentSessions)
                        .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showTrickSelector) {
            TrickSelectorForTraining(
                user: appState.currentUser,
                selectedTricks: $selectedTricksToTrain,
                onStart: {
                    showTrickSelector = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSessionView = true
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showSessionView) {
            TrainingSessionView(
                selectedTricks: Array(selectedTricksToTrain),
                onEnd: { session in
                    trainingVM.saveSession(session, user: &appState.currentUser)
                    if let user = appState.currentUser {
                        appState.saveUser(user)
                    }
                    // Update streak
                    streakService.updateStreak(with: trainingVM.recentSessions)
                    // Check achievements
                    appState.checkAchievements()
                    showSessionView = false
                }
            )
            .environmentObject(appState)
        }
        .onAppear {
            trainingVM.loadSessions()
            streakService.updateStreak(with: trainingVM.recentSessions)
        }
    }
}
