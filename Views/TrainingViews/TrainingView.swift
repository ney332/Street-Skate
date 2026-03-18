import SwiftUI
import MapKit

struct TrainingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var trainingVM = TrainingViewModel()
    @StateObject private var streakService = StreakService()
    @State private var showSessionView = false
    @State private var showTrickSelector = false
    @State private var selectedTricksToTrain: Set<String> = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Training")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Time to shred 🛹")
                            .font(.system(size: 15))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    // Start Training Card
                    StartTrainingCard(onStart: { showTrickSelector = true })
                        .padding(.horizontal, 20)
                    
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
                    // Save to HealthKit
                    Task { await HealthKitService.shared.saveSkateWorkout(session: session) }
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

// MARK: - Start Training Card
struct StartTrainingCard: View {
    let onStart: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onStart) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#1c1c1e")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(24)
                
                // Glow dot
//                Circle()
//                    .fill(Color(hex: "#FFD700").opacity(0.2))
//                    .frame(width: 120, height: 120)
//                    .blur(radius: 30)
//                    .offset(x: 80, y: -30)
                
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#FFD700").opacity(0.15))
                                .frame(width: 60, height: 60)
                            Image(systemName: "play.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "#FFD700"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Session")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Choose tricks and hit the road")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        
                        HStack(spacing: 16) {
                            InfoPill(icon: "timer", text: "Track time")
                            InfoPill(icon: "location.fill", text: "GPS route")
                        }
                    }
                    Spacer()
                }
                .padding(24)
            }
            .frame(height: 200)
            .shadow(color: Color(hex: "#FFD700").opacity(0.1), radius: 20, y: 8)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#FFD700"))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

// MARK: - Daily Metrics Section
struct DailyMetricsSection: View {
    @ObservedObject var trainingVM: TrainingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                DailyMetricCard(
                    value: String(format: "%.0f", trainingVM.todayCalories),
                    unit: "kcal",
                    label: "Calories",
                    icon: "flame.fill",
                    color: Color(hex: "#FF6B35"),
                    progress: min(trainingVM.todayCalories / 500, 1.0)
                )
                DailyMetricCard(
                    value: String(format: "%.2f", trainingVM.todayDistanceKm),
                    unit: "km",
                    label: "Distance",
                    icon: "figure.skating",
                    color: Color(hex: "#2196F3"),
                    progress: min(trainingVM.todayDistanceKm / 5, 1.0)
                )
                DailyMetricCard(
                    value: "\(trainingVM.todayPushCount)",
                    unit: "rmd",
                    label: "Remadas",
                    icon: "arrow.forward",
                    color: Color(hex: "#4CAF50"),
                    progress: min(Double(trainingVM.todayPushCount) / 200, 1.0)
                )
            }
            
            // Activity Ring Inspired Card
            ActivitySummaryCard(trainingVM: trainingVM)
        }
    }
}

struct DailyMetricCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 4)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ActivitySummaryCard: View {
    @ObservedObject var trainingVM: TrainingViewModel
    
    let hours = Array(0..<24)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Activity Today")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("Last 24h")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            
            // Activity bars
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(0..<24, id: \.self) { hour in
                    let activity = trainingVM.activityByHour[hour] ?? 0
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            activity > 0
                            ? LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")], startPoint: .bottom, endPoint: .top)
                            : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.06)], startPoint: .bottom, endPoint: .top)
                        )
                        .frame(height: max(4, CGFloat(activity) * 40))
                }
            }
            .frame(height: 40)
            
            HStack {
                Text("12am")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.3))
                Spacer()
                Text("Now")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.3))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Recent Sessions
struct RecentSessionsSection: View {
    let sessions: [TrainingSession]
    @State private var selectedSession: TrainingSession? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Sessions")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            if sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.skating")
                        .font(.system(size: 36))
                        .foregroundColor(Color.white.opacity(0.2))
                    Text("No sessions yet")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.3))
                    Text("Start your first skate session!")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(sessions) { session in
                    Button(action: { selectedSession = session }) {
                        SessionRowCard(session: session)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailView(session: session)
                .environmentObject(AppState())
        }
    }
}

struct SessionRowCard: View {
    let session: TrainingSession
    
    var durationText: String {
        let minutes = Int(session.duration) / 60
        let seconds = Int(session.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#FFD700").opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "figure.skating")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#FFD700"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("\(durationText) • \(String(format: "%.2f", session.distanceKm))km")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(session.calories))")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(Color(hex: "#FF6B35"))
                Text("kcal")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.3))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Trick Selector for Training
struct TrickSelectorForTraining: View {
    let user: UserProfile?
    @Binding var selectedTricks: Set<String>
    let onStart: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("What will you practice?")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(SkateTrick.allTricks) { trick in
                                let isUnlocked = user?.unlockedTricks.contains(trick.name) ?? false
                                let isSelected = selectedTricks.contains(trick.name)
                                
                                Button(action: {
                                    if isSelected {
                                        selectedTricks.remove(trick.name)
                                    } else {
                                        selectedTricks.insert(trick.name)
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(trick.name)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(trick.category.rawValue)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.white.opacity(0.4))
                                        }
                                        Spacer()
                                        if isUnlocked {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(Color(hex: "#FFD700"))
                                                .font(.system(size: 14))
                                        }
                                        ZStack {
                                            Circle()
                                                .stroke(isSelected ? Color(hex: "#FFD700") : Color.white.opacity(0.2), lineWidth: 2)
                                                .frame(width: 24, height: 24)
                                            if isSelected {
                                                Circle()
                                                    .fill(Color(hex: "#FFD700"))
                                                    .frame(width: 14, height: 14)
                                            }
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(isSelected ? Color(hex: "#FFD700").opacity(0.08) : Color.white.opacity(0.04))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(isSelected ? Color(hex: "#FFD700").opacity(0.3) : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    
                    VStack(spacing: 0) {
                        Divider().background(Color.white.opacity(0.1))
                        Button(action: onStart) {
                            PrimaryButton(title: selectedTricks.isEmpty ? "Start Free Session" : "Start with \(selectedTricks.count) tricks", isEnabled: true)
                        }
                        .padding(20)
                    }
                    .background(Color.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
