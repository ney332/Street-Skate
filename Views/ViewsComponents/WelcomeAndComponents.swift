import SwiftUI

// MARK: - Welcome View
struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 30
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFD700").opacity(0.15))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 104, height: 104)
                            .shadow(color: Color(hex: "#FFD700").opacity(0.4), radius: 24)
                        
                        Text("SK8")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 16) {
                    Text("Welcome to\nStreet skate")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("Your personal skating companion.\nTrack sessions, unlock tricks, find spots.")
                        .font(.system(size: 17))
                        .foregroundColor(Color.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Feature pills
                HStack(spacing: 12) {
                    FeaturePill(icon: "location.fill", text: "Find Spots")
                    FeaturePill(icon: "figure.skating", text: "Track Sessions")
                    FeaturePill(icon: "star.fill", text: "Earn XP")
                }
                .padding(.bottom, 48)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState.appPhase = .main
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Start skating")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: Color(hex: "#FFD700").opacity(0.35), radius: 16, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
            }
            .opacity(opacity)
            .offset(y: offset)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                opacity = 1
                offset = 0
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#FFD700"))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Shared UI Components

struct FloatingTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(text.isEmpty ? Color.white.opacity(0.4) : Color(hex: "#FFD700"))
                .frame(width: 20)
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(Color.white.opacity(0.35))
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(text.isEmpty ? Color.white.opacity(0.1) : Color(hex: "#FFD700").opacity(0.5), lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    
    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(isEnabled ? .black : Color.white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled
                        ? LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: isEnabled ? Color(hex: "#FFD700").opacity(0.3) : .clear, radius: 12, y: 4)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(Color.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - View Extension
extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
