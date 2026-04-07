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
    @Environment(\.dismiss) var dismiss


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
                    .stroke(Color(hex: "#87FF00"), lineWidth: 4)
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
                    Button(action: {
                        if sessionVM.isRunning || sessionVM.startTime != nil {
                            showEndConfirm = true
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

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
                        .background(Color(hex: "#87FF00").opacity(0.9))
                        .cornerRadius(20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                // Metrics panel with live push count from MotionService
                SessionMetricsPanel(
                    sessionVM: sessionVM,
                    pushCount: displayPushCount,
                    onStart: {
                        sessionVM.userName = appState.currentUser?.name ?? "Skater"
                        sessionVM.startSession()
                        motionService.startTracking()
                    },
                    onEnd: { showEndConfirm = true }
                )
            }
        }
        .alert("End Session?".localized, isPresented: $showEndConfirm) {
            Button("End Session".localized, role: .destructive) {
                Task {
                    motionService.stopTracking()
                    var session = await sessionVM.endSession()
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
            }
            Button("Keep Going".localized, role: .cancel) {}
        } message: {
            Text("Your session will be saved.".localized)
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
