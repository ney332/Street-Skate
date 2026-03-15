import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            TrainingView()
                .tag(1)
                .tabItem {
                    Image(systemName: "figure.skating")
                    Text("Train")
                }

            SettingsView()
                .tag(2)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        // Prefer native tab bar appearance
        .tabViewStyle(.automatic)
        // Apply a Liquid Glass-like material to the tab bar background
        // On iOS 18+/modern SwiftUI, using .toolbarBackground supports materials.
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        // Optional: tint the selected item to your gold color
        .tint(Color(hex: "#FFD700"))
    }
}

// If you still want to keep the custom bar for reference, you can comment it out or remove it entirely.
// The native TabView now provides the tab bar. The previous CustomTabBar is no longer used.

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("figure.skating", "Train"),
        ("gearshape.fill", "Settings")
    ]

    var body: some View {
        // Deprecated: Using native TabView with .tabItem now.
        EmptyView()
    }
}
