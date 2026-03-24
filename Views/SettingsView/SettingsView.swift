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
    @State private var healthKitEnabled = true {
        didSet {
            if healthKitEnabled {
                Task { await HealthKitService.shared.requestAuthorization() }
            }
        }
    }
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
                    Text("Settings")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    
                    // Profile card
                    ProfileCard(user: user)
                        .padding(.horizontal, 20)
                    
                    SettingsSection(title: "Data & Activity") {
                        NavigationRowSettings(icon: "figure.skateboarding", iconColor: Color(hex: "#4CAF50"), title: "Game Skate") {
                            showDrawSkate = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "chart.xyaxis.line", iconColor: Color(hex: "#2196F3"), title: "Progress Charts") {
                            showProgress = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "trophy.fill", iconColor: Color(hex: "#FFD700"), title: "Achievements") {
                            showAchievements = true
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Notifications section
                    SettingsSection(title: "Preferences") {
                        ToggleRow(icon: "bell.fill", iconColor: Color(hex: "#FF9800"), title: "Notifications", isOn: $notificationsEnabled)
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        ToggleRow(icon: "location.fill", iconColor: Color(hex: "#2196F3"), title: "Location Services", isOn: $locationEnabled)
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        ToggleRow(icon: "heart.fill", iconColor: Color(hex: "#F44336"), title: "Health & Fitness", isOn: $healthKitEnabled)
                    }
                    .padding(.horizontal, 20)
                    
                    // App info section
    SettingsSection(title: "Information") {
                        NavigationRowSettings(icon: "trophy.fill", iconColor: Color(hex: "#FFD700"), title: "Achievements") {
                            showAchievements = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "chart.xyaxis.line", iconColor: Color(hex: "#4CAF50"), title: "Progress") {
                            showProgress = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "info.circle.fill", iconColor: Color(hex: "#2196F3"), title: "About") {
                            showAbout = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "hand.raised.fill", iconColor: Color(hex: "#9C27B0"), title: "Privacy Policy") {
                            showPrivacy = true
                        }
                        Divider().background(Color.white.opacity(0.08)).padding(.leading, 54)
                        NavigationRowSettings(icon: "star.fill", iconColor: Color(hex: "#FFD700"), title: "Rate the App") {}
                    }
                    .padding(.horizontal, 20)
                    
                    // Danger zone
                    SettingsSection(title: "Account") {
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
                                Text("Sign Out & Reset")
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
                    Text("SkateFlow v1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.2))
                        .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .alert("Reset Everything?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) {
                appState.resetSession()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all your data and progress. This cannot be undone.")
        }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showPrivacy) { PrivacyView() }
        .sheet(isPresented: $showAchievements) { AchievementsView().environmentObject(appState) }
        .sheet(isPresented: $showProgress) { ProgressView().environmentObject(appState) }
        .sheet(isPresented: $showDrawSkate) { SkateDrawView(showDrawSkate: true) }
        .fullScreenCover(isPresented: $showSpotsMap) { AllSpotsMapView() }
    }
}

// MARK: - Profile Card
struct ProfileCard: View {
    let user: UserProfile?
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                LinearGradient(
                    colors: [Color("verde"), Color("verde")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                
                Text(String(user?.name.prefix(1) ?? "S").uppercased())
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user?.name ?? "Skater")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(user?.level.rawValue ?? "Amateur")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("verde"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#FFD700").opacity(0.12))
                        .cornerRadius(8)
                    
                    Text("Age \(user?.age ?? 0)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                Text("\(user?.xp ?? 0) XP total")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("verde").opacity(0.15), lineWidth: 1)
                )
        )
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

struct ToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color("verde"))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct NavigationRowSettings: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - About and Privacy
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [Color("verde"), Color("verde")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        Image("AppIcon")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        Text("Street Skate")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Version 1.0.0")
                            .font(.system(size: 15))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    
                    Text("Street Skate is your ultimate companion for tracking skate sessions, discovering spots, and progressing your trick skills. Built for skaters, by skaters.")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Color("verde"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach([
                            ("Data Collection", "We collect location data only during active training sessions to track your route and calculate distance."),
                            ("Health Data", "HealthKit integration is optional and used only to read and write workout data with your explicit permission."),
                            ("Local Storage", "All your profile and session data is stored locally on your device. We do not upload data to external servers."),
                            ("Third Parties", "We do not share your personal data with any third parties.")
                        ], id: \.0) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.0)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                Text(item.1)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Color("verde"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


