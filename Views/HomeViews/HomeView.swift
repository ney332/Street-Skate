import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationVM = LocationViewModel()
    @StateObject private var spotsService = SpotsService()
    @State private var showTricksView = false
    @State private var showAchievements = false
    @State private var showProgress = false
    @State private var showAchievementToast = false
    @State private var showTrickLog = false
    @State private var showAllSpots = false
    @State private var showAllLevels = false
    
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
                            // XP Level card
                            if let u = user {
                                Button(action: { showAllLevels = true }) {
                                    XPLevelCard(user: u)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                            
                            // Tricks + Log Row
                            HStack(spacing: 12) {
                                Button(action: { showTricksView = true }) {
                                    TricksSummaryCardCompact(user: user)
                                }
                                .buttonStyle(.plain)

                                Button(action: { showTrickLog = true }) {
                                    TrickLogCardCompact()
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            
                            // Nearby Spots
                            NearbySection(spotsService: spotsService, locationVM: locationVM, onMapTap: { showAllSpots = true })
                            
                            // Full Tricks Library card
                            TricksSummaryCard(user: user, onTap: { showTricksView = true })
                                .padding(.horizontal, 20)
                            
                            // Metrics Card
                            MetricsCard(user: user, onProgressTap: { showProgress = true })
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                if showAchievementToast, let achievement = appState.achievementManager.newlyUnlocked {
                    AchievementToast(achievement: achievement, isShowing: $showAchievementToast)
                        .zIndex(10)
                }
            }
            .sheet(isPresented: $showTricksView) { TricksLibraryView().environmentObject(appState) }
            .sheet(isPresented: $showAchievements) { AchievementsView().environmentObject(appState) }
            .sheet(isPresented: $showProgress) { ProgressView().environmentObject(appState) }
            .sheet(isPresented: $showTrickLog) { TrickLogView().environmentObject(appState) }
            .fullScreenCover(isPresented: $showAllSpots) { AllSpotsMapView() }
            .sheet(isPresented: $showAllLevels) {
                AllLevelsView(userXP: user?.xp ?? 0)
            }
            .onAppear { locationVM.requestLocation() }
            .onChange(of: locationVM.currentLocation) { _, newLocation in
                if let loc = newLocation, spotsService.nearbySpots.isEmpty {
                    spotsService.searchNearbySpots(location: loc)
                }
            }
            .onChange(of: appState.achievementManager.newlyUnlocked != nil) { _, hasNew in
                if hasNew {
                    withAnimation(.spring()) { showAchievementToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation { showAchievementToast = false }
                    }
                }
            }
        }
    }
}

// MARK: - Home Header
struct HomeHeader: View {
    let user: UserProfile?
    var onAchievementsTap: (() -> Void)? = nil
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        else if hour < 17 { return "Good afternoon" }
        else { return "Good evening" }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting + ",")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                Text(user?.name ?? "Skater")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Achievements button
            Button(action: { onAchievementsTap?() }) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#FFD700"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "#FFD700").opacity(0.12))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "#FFD700").opacity(0.2), lineWidth: 1))
            }
            
            // XP Badge
            VStack(spacing: 2) {
                Text("\(user?.xp ?? 0)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "#FFD700"))
                Text("XP")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#FFD700").opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#FFD700").opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Tricks Summary Card
struct TricksSummaryCard: View {
    let user: UserProfile?
    let onTap: () -> Void
    
    var unlockedCount: Int { user?.unlockedTricks.count ?? 0 }
    var totalCount: Int { SkateTrick.allTricks.count }
    var progress: Double { totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0 }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trick Library")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.5))
                            .textCase(.uppercase)
                            .tracking(1)
                        Text("Your Arsenal")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.3))
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Label("\(unlockedCount) unlocked", systemImage: "lock.open.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#FFD700"))
                    Spacer()
                    Text("\(totalCount - unlockedCount) to go")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                // Sample trick chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach((user?.unlockedTricks ?? []).prefix(6), id: \.self) { trick in
                            Text(trick)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color(hex: "#FFD700")))
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

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
                    .foregroundColor(Color(hex: "#FFD700"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.2))
            }
            Text("\(unlockedCount)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Tricks\nUnlocked")
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.45))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#FFD700").opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Compact Trick Log Card
struct TrickLogCardCompact: View {
    var recentCount: Int { TrickLogService.shared.entries.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "list.clipboard.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#4CAF50"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.2))
            }
            Text("\(recentCount)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Log\nEntries")
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.45))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#4CAF50").opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Nearby Spots Section
struct NearbySection: View {
    @ObservedObject var spotsService: SpotsService
    @ObservedObject var locationVM: LocationViewModel
    var onMapTap: (() -> Void)? = nil

    let mockSpots: [SkateSpot] = [
        SkateSpot(name: "Local Skate Park", type: .park, coordinate: CLLocationCoordinate2D(latitude: -22.9, longitude: -43.17), distanceMeters: 350, rating: 4.7, imageName: "skateboard"),
        SkateSpot(name: "Downtown Plaza", type: .plaza, coordinate: CLLocationCoordinate2D(latitude: -22.93, longitude: -43.17), distanceMeters: 870, rating: 4.5, imageName: "skateboard"),
        SkateSpot(name: "City Bowl", type: .bowl, coordinate: CLLocationCoordinate2D(latitude: -23.0, longitude: -43.37), distanceMeters: 2100, rating: 4.8, imageName: "skateboard"),
    ]

    var displaySpots: [SkateSpot] {
        spotsService.nearbySpots.isEmpty ? mockSpots : spotsService.nearbySpots
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Nearby Spots")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()

                if spotsService.isLoading {
                    ProgressView().scaleEffect(0.8).tint(Color(hex: "#FFD700"))
                } else {
                    Button(action: { onMapTap?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#FFD700"))
                            Text("Map View")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#FFD700"))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(displaySpots) { spot in
                        NavigationLink(destination: SpotDetailView(spot: spot)) {
                            SpotCard(spot: spot)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SpotCard: View {
    let spot: SkateSpot
    
    var typeColor: Color {
        switch spot.type {
        case .park: return Color(hex: "#4CAF50")
        case .plaza: return Color(hex: "#2196F3")
        case .street: return Color(hex: "#FF9800")
        case .bowl: return Color(hex: "#9C27B0")
        case .diy: return Color(hex: "#F44336")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Map preview placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 90)
                
                Image(systemName: spot.type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(typeColor.opacity(0.7))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(spot.type.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(typeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(typeColor.opacity(0.15))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Image(systemName: "location")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.4))
                    Text(spot.distanceText)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#FFD700"))
                    Text(String(format: "%.1f", spot.rating))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Metrics Card
struct MetricsCard: View {
    let user: UserProfile?
    var onProgressTap: (() -> Void)? = nil

    private var xpText: String {
        let currentXP = user?.xp ?? 0
        let nextThreshold = ((currentXP / 1000) + 1) * 1000
        return "\(currentXP) / \(nextThreshold) XP"
    }

    private var levelProgress: Double {
        user?.levelProgress ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("All Time Stats")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text(user?.level.rawValue ?? "")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#FFD700"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#FFD700").opacity(0.15))
                    .cornerRadius(8)
            }

            HStack(spacing: 12) {
                StatBox(value: "\(user?.totalSessions ?? 0)", label: "Sessions", icon: "calendar")
                StatBox(value: String(format: "%.1f", user?.totalDistanceKm ?? 0) + "km", label: "Distance", icon: "arrow.triangle.swap")
                StatBox(value: "\(Int(user?.totalCalories ?? 0))", label: "Calories", icon: "flame.fill")
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Level Progress")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.5))
                    Spacer()
                    Text(xpText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#FFD700"))
                }

                LevelProgressBar(progress: levelProgress)
                    .frame(height: 10)
            }

            Button(action: { onProgressTap?() }) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 14))
                    Text("View Detailed Progress")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "#FFD700"))
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct LevelProgressBar: View {
    let progress: Double

    var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700"), Color(hex: "#FF6B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * clampedProgress, height: 10)
                    .shadow(color: Color(hex: "#FFD700").opacity(0.4), radius: 4)
            }
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#FFD700"))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

