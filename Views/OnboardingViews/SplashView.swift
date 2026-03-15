import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
//            Color.black.ignoresSafeArea()
            Image("LoadOnboarding")
            
            // Subtle grid pattern
//            GeometryReader { geo in
//                Canvas { context, size in
//                    let spacing: CGFloat = 40
//                    context.opacity = 0.04
//                    var path = Path()
//                    var x: CGFloat = 0
//                    while x <= size.width {
//                        path.move(to: CGPoint(x: x, y: 0))
//                        path.addLine(to: CGPoint(x: x, y: size.height))
//                        x += spacing
//                    }
//                    var y: CGFloat = 0
//                    while y <= size.height {
//                        path.move(to: CGPoint(x: 0, y: y))
//                        path.addLine(to: CGPoint(x: size.width, y: y))
//                        y += spacing
//                    }
//                    context.stroke(path, with: .color(.white), lineWidth: 0.5)
//                }
            }
            .ignoresSafeArea()
            
//            VStack(spacing: 24) {
//                // Logo Mark
//                ZStack {
//                    // Glow effect
//                    Circle()
//                        .fill(Color.yellow.opacity(0.15))
//                        .frame(width: 120, height: 120)
//                        .blur(radius: glowRadius)
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 28)
//                            .fill(
//                                LinearGradient(
//                                    colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .frame(width: 96, height: 96)
//                            .shadow(color: Color(hex: "#FFD700").opacity(0.4), radius: 20, x: 0, y: 8)
//                        
//                        Text("SK8")
//                            .font(.system(size: 32, weight: .black, design: .rounded))
//                            .foregroundColor(.black)
//                    }
//                }
//                .scaleEffect(logoScale)
//                .opacity(logoOpacity)
//                
//                // App name
//                VStack(spacing: 6) {
//                    Text("SKATEFLOW")
//                        .font(.system(size: 28, weight: .black, design: .rounded))
//                        .foregroundColor(.white)
//                        .tracking(6)
//                    
//                    Text("Track. Skate. Progress.")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(Color.white.opacity(0.5))
//                        .tracking(2)
//                }
//                .opacity(taglineOpacity)
//            }
        }
//        .onAppear {
//            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
//                logoScale = 1.0
//                logoOpacity = 1.0
//            }
//            withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
//                taglineOpacity = 1.0
//                glowRadius = 30
//            }
//        }
//    }
}
#Preview {
    SplashView()
}
