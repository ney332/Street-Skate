import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showResetConfirm = false
    @State private var notificationsEnabled = true {
        didSet {
            if notificationsEnabled {
                Task {
                    let granted = await NotificationService.shared.requestAuthorization()
                    if granted {
                        NotificationService.shared.scheduleDailyReminder()
                        NotificationService.shared.scheduleStreakWarning()
                    }
                }
            } else {
                NotificationService.shared.cancelAll()
            }
        }
    }
    @State private var locationEnabled = true
    @State private var healthKitEnabled = false
    @State private var showDrawSkate = false
    @State private var showAbout = false
    @State private var showPrivacy = false
    @State private var showAchievements = false
    @State private var showProgress = false
    @State private var showTrickLog = false
    @State private var showEditProfile = false
    @State private var showSpotsMap = false
    
    var user: UserProfile? { appState.currentUser }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Settings".localized)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    
                    // Profile card
                    ProfileCard(user: user)
                        .padding(.horizontal, 20)
                    
                    SettingsSection(title: "Data & Activity".localized) {
                        NavigationRowSettings(icon: "figure.skateboarding", iconColor: Color(hex: "#4CAF50"), title: "Game Skate".localized) {
                            showDrawSkate = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "chart.xyaxis.line", iconColor: Color(hex: "#2196F3"), title: "Progress Charts".localized) {
                            showProgress = true
                        }
                      
                    }
                    .padding(.horizontal, 20)
                    
                    // Notifications section
                    SettingsSection(title: "Preferences".localized) {
                        ToggleRow(icon: "bell.fill", iconColor: Color(hex: "#FF9800"), title: "Notifications".localized, isOn: $notificationsEnabled)
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        ToggleRow(icon: "location.fill", iconColor: Color(hex: "#2196F3"), title: "Location Services".localized, isOn: $locationEnabled)
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        ToggleRow(icon: "heart.fill", iconColor: Color(hex: "#F44336"), title: "Health & Fitness".localized, isOn: $healthKitEnabled)
                    }
                    .padding(.horizontal, 20)
                    
                    // App info section
    SettingsSection(title: "Information".localized) {
                        NavigationRowSettings(icon: "trophy.fill", iconColor: Color(hex: "#FFD700"), title: "Achievements".localized) {
                            showAchievements = true
                        }
                
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "info.circle.fill", iconColor: Color(hex: "#2196F3"), title: "About".localized) {
                            showAbout = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "hand.raised.fill", iconColor: Color(hex: "#9C27B0"), title: "Privacy Policy".localized) {
                            showPrivacy = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "star.fill", iconColor: Color(hex: "#FFD700"), title: "Rate the App".localized) {}
                    }
                    .padding(.horizontal, 20)
                    
                    // Danger zone
                    SettingsSection(title: "Account".localized) {
                        Button(action: { showResetConfirm = true }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#F44336").opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#F44336"))
                                }
                                Text("Sign Out & Reset".localized)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#F44336"))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Version
                    Text("about.made_by".localized)
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .scrollIndicators(.hidden)
        }
        .alert("Reset Everything?".localized, isPresented: $showResetConfirm) {
            Button("Reset".localized, role: .destructive) {
                appState.resetSession()
            }
            Button("Cancel".localized, role: .cancel) {}
        } message: {
            Text("This will delete all your data and progress. This cannot be undone.".localized)
        }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showPrivacy) { PrivacyView() }
        .sheet(isPresented: $showAchievements) { AchievementsView().environmentObject(appState) }
        .sheet(isPresented: $showProgress) { ProgressView().environmentObject(appState) }
        .sheet(isPresented: $showDrawSkate) { SkateDrawView(showDrawSkate: true) }
        .fullScreenCover(isPresented: $showSpotsMap) { AllSpotsMapView() }
    }
}
// MARK: - Settings Components
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.4))
                .tracking(1)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
            )
        }
    }
}
