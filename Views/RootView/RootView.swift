import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            switch appState.appPhase {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .onboarding:
                OnboardingContainerView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .welcome:
                WelcomeView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .main:
                MainTabView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.appPhase)
        .onAppear {
            if appState.appPhase == .splash {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        appState.appPhase = appState.hasCompletedOnboarding ? .main : .onboarding
                    }
                }
            }
        }
    }
}
