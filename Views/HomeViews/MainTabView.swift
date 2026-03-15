import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                TrainingView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("figure.skating", "Train"),
        ("gearshape.fill", "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = i
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[i].icon)
                            .font(.system(size: selectedTab == i ? 22 : 20))
                            .foregroundColor(selectedTab == i ? Color(hex: "#FFD700") : Color.white.opacity(0.4))
                            .scaleEffect(selectedTab == i ? 1.1 : 1.0)
                        
                        Text(tabs[i].label)
                            .font(.system(size: 11, weight: selectedTab == i ? .bold : .regular))
                            .foregroundColor(selectedTab == i ? Color(hex: "#FFD700") : Color.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.white.opacity(0.1)),
                    alignment: .top
                )
        )
        .environment(\.colorScheme, .dark)
    }
}
