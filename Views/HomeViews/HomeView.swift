import SwiftUI
import MapKit



struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationVM: LocationViewModel
    @EnvironmentObject var spotsService: SpotsService
    
    @State private var showTricksView = false
    @State private var showAchievements = false
    @State private var showProgress = false
    @State private var showAchievementToast = false
    @State private var showTrickLog = false
    @State private var showAllSpots = false
    @State private var showAllLevels = false
    @State private var showTrickSelector: Bool = false

    @StateObject private var trainingVM = TrainingViewModel()
    @StateObject private var streakService = StreakService()
    @State private var showSessionView = false

    @State private var selectedTricksToTrain: Set<String> = []

    var user: UserProfile? { appState.currentUser }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        HomeHeader(user: user, onAchievementsTap: { showAchievements = true })
                            .padding(.top, 60)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 20) {
                            
                            StartTrainingCard(onStart: {
                                showTrickSelector = true
                            })
                            .padding(.horizontal, 20)
                            
                            // Tricks + Spots
                            HStack(spacing: 12) {
                                Button(action: { showTricksView = true }) {
                                    TricksSummaryCardCompact(user: user)
                                }
                                .buttonStyle(.plain)

                                Button(action: { showAllSpots = true }) {
                                    AllspotsCardCompact(spotsService: spotsService)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            
                            // Nearby Spots
                            NearbySection(
                                spotsService: spotsService,
                                locationVM: locationVM,
                                onMapTap: { showAllSpots = true }
                            )
                            
                            TricksSummaryCard(user: user, onTap: { showTricksView = true })
                                .padding(.horizontal, 20)
                            
                            // Metrics
                            MetricsCard(user: user, onProgressTap: { showProgress = true })
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                // Toast
                if showAchievementToast,
                   let achievement = appState.achievementManager.newlyUnlocked {
                    AchievementToast(
                        achievement: achievement,
                        isShowing: $showAchievementToast
                    )
                    .zIndex(10)
                }
            }
            
            // 🔥 SELECT TRICKS
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
            
            // 🔥 SESSION VIEW (FALTAVA ISSO)
//            .fullScreenCover(isPresented: $showSessionView) {
//                TrainingSessionView(tricks: selectedTricksToTrain)
//            }
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
            // Sheets
            .sheet(isPresented: $showTricksView) {
                TricksLibraryView().environmentObject(appState)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView().environmentObject(appState)
            }
            .sheet(isPresented: $showProgress) {
                ProgressView().environmentObject(appState)
            }
            .sheet(isPresented: $showTrickLog) {
                TrickLogView().environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showAllSpots) {
                AllSpotsMapView()
            }
            .sheet(isPresented: $showAllLevels) {
                AllLevelsView(userXP: user?.xp ?? 0)
            }
            
            // Location
            .onAppear {
                locationVM.requestLocation()
            }
            .onChange(of: locationVM.currentLocation) { _, newLocation in
                if let loc = newLocation {
                    spotsService.refreshNearbySpotsIfNeeded(location: loc)
                }
            }
            
            // Achievements toast
            .onChange(of: appState.achievementManager.newlyUnlocked != nil) { _, hasNew in
                if hasNew {
                    withAnimation(.spring()) {
                        showAchievementToast = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            showAchievementToast = false
                        }
                    }
                }
            }
        }
    }
}
// MARK: - Home Header

// MARK: - Tricks Summary Card


// MARK: - Compact Tricks Card (for row layout)
struct TricksSummaryCardCompact: View {
    let user: UserProfile?
    var unlockedCount: Int { user?.unlockedTricks.count ?? 0 }
    var totalCount: Int { SkateTrick.allTricks.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color("verde"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.2))
            }
            Text("\(unlockedCount)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Tricks\nUnlocked".localized)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.45))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color("verde").opacity(0.15), lineWidth: 1))
        )
    }
}
