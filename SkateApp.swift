import SwiftUI

@main
struct SkateAppApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationVM = LocationViewModel()
    @StateObject private var spotsService = SpotsService()


    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(locationVM)
                .environmentObject(spotsService)
                .preferredColorScheme(.dark)
                .task {
                    // Request notification permission after a short delay
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    let granted = await NotificationService.shared.requestAuthorization()
                    if granted {
                        NotificationService.shared.scheduleDailyReminder()
                        NotificationService.shared.scheduleStreakWarning()
                        GPSIndicatorView(viewModel: locationVM)
                    }
                }
        }
    }
}
