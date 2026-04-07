import SwiftUI

struct FeaturePill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color("verde"))
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
                .foregroundColor(text.isEmpty ? Color.white.opacity(0.4) : Color("verde"))
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
                        .stroke(text.isEmpty ? Color.white.opacity(0.1) : Color("verde").opacity(0.5), lineWidth: 1.5)
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
                        ? LinearGradient(colors: [Color("verde"), Color(hex: "#FF8C00")], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: isEnabled ? Color("verde").opacity(0.3) : .clear, radius: 12, y: 4)
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
