import SwiftUI
import MapKit

struct TrainingSessionView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var sessionVM = SessionViewModel()
    @StateObject private var motionService = MotionService.shared
    let selectedTricks: [String]
    let onEnd: (TrainingSession) -> Void

    @State private var showEndConfirm = false
    @State private var showSummary = false
    @State private var completedSession: TrainingSession? = nil
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapStyle: MapStyle = .standard(elevation: .realistic)
    @State private var lastMilestonKm: Double = 0
    @State private var showMilestoneToast = false
    @State private var milestoneText = ""

    // Merge MotionService pushes into sessionVM display
    var displayPushCount: Int {
        max(sessionVM.pushCount, motionService.pushCount)
    }

    var body: some View {
        ZStack {
            // Full screen map
            Map(position: $cameraPosition) {
                UserAnnotation()
                if sessionVM.routePoints.count > 1 {
                    MapPolyline(coordinates: sessionVM.routePoints.map {
                        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                    })
                    .stroke(Color(hex: "#FFD700"), lineWidth: 4)
                }
            }
            .mapStyle(mapStyle)
            .ignoresSafeArea()
            .onTapGesture {
                // Toggle map style on double tap handled below
            }

            // Top overlay
            VStack {
                HStack {
                    Button(action: { showEndConfirm = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Speed indicator (when running)
                    if sessionVM.isRunning && motionService.currentSpeedKmh > 0.5 {
                        HStack(spacing: 6) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 12))
                            Text(String(format: "%.1f km/h", motionService.currentSpeedKmh))
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    }

                    // Live badge
                    HStack(spacing: 8) {
                        Circle()
                            .fill(sessionVM.isRunning ? Color(hex: "#4CAF50") : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(sessionVM.isRunning ? "LIVE" : sessionVM.startTime == nil ? "READY" : "PAUSED")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.white)
                            .tracking(2)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                // Milestone toast
                if showMilestoneToast {
                    Text(milestoneText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FFD700").opacity(0.9))
                        .cornerRadius(20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                // Metrics panel with live push count from MotionService
                SessionMetricsPanel(
                    sessionVM: sessionVM,
                    pushCount: displayPushCount,
                    onStart: {
                        sessionVM.startSession()
                        motionService.startTracking()
                    },
                    onEnd: { showEndConfirm = true }
                )
            }
        }
        .alert("End Session?", isPresented: $showEndConfirm) {
            Button("End Session", role: .destructive) {
                motionService.stopTracking()
                var session = sessionVM.endSession()
                session = TrainingSession(
                    id: session.id,
                    date: session.date,
                    duration: session.duration,
                    distanceKm: session.distanceKm,
                    calories: session.calories,
                    pushCount: displayPushCount,
                    tricksAttempted: selectedTricks,
                    routePoints: session.routePoints
                )
                completedSession = session
                showSummary = true
            }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your session will be saved.")
        }
        .fullScreenCover(isPresented: $showSummary) {
            if let session = completedSession {
                SessionSummaryView(
                    session: session,
                    newAchievements: appState.achievementManager.achievements.filter {
                        if let date = $0.unlockedAt { return Calendar.current.isDateInToday(date) }
                        return false
                    },
                    onDismiss: {
                        showSummary = false
                        onEnd(session)
                    }
                )
            }
        }
        .onAppear { sessionVM.setupLocation() }
        .onChange(of: sessionVM.distanceKm) { _, km in
            checkMilestone(km: km)
        }
    }

    func checkMilestone(km: Double) {
        let milestones = [0.5, 1.0, 2.0, 3.0, 5.0]
        for m in milestones {
            if km >= m && lastMilestonKm < m {
                lastMilestonKm = m
                milestoneText = "🎯 \(m < 1 ? "\(Int(m * 1000))m" : "\(Int(m))km") skated!"
                withAnimation(.spring()) { showMilestoneToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { showMilestoneToast = false }
                }
                NotificationService.shared.sendMilestoneNotification(km: km)
            }
        }
    }
}

// MARK: - Session Metrics Panel
struct SessionMetricsPanel: View {
    @ObservedObject var sessionVM: SessionViewModel
    var pushCount: Int = 0
    let onStart: () -> Void
    let onEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Metrics grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    SessionMetric(
                        value: sessionVM.formattedDuration,
                        label: "Duration",
                        icon: "timer"
                    )
                    SessionMetric(
                        value: String(format: "%.2f", sessionVM.distanceKm),
                        label: "km",
                        icon: "arrow.triangle.swap"
                    )
                }
                HStack(spacing: 16) {
                    SessionMetric(
                        value: "\(Int(sessionVM.calories))",
                        label: "Calories",
                        icon: "flame.fill"
                    )
                    SessionMetric(
                        value: "\(pushCount > 0 ? pushCount : sessionVM.pushCount)",
                        label: "Remadas",
                        icon: "arrow.forward.circle"
                    )
                }
            }
            .padding(20)
            
            Divider().background(Color.white.opacity(0.1))
            
            // Action buttons
            HStack(spacing: 12) {
                if !sessionVM.isRunning && sessionVM.startTime == nil {
                    Button(action: onStart) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Start")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                    }
                } else {
                    Button(action: {
                        if sessionVM.isRunning { sessionVM.pauseSession() } else { sessionVM.resumeSession() }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: sessionVM.isRunning ? "pause.fill" : "play.fill")
                            Text(sessionVM.isRunning ? "Pause" : "Resume")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    Button(action: onEnd) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text("End Session")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                    }
                }
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 12)
        .padding(.bottom, 30)
    }
}

struct SessionMetric: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "#FFD700"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
    }
}
