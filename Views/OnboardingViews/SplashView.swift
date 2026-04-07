import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background

            Image("LoadOnboarding")

            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
                    taglineOpacity = 1.0
                    glowRadius = 30
                }


        }
        }
}
#Preview {
    SplashView()
}
