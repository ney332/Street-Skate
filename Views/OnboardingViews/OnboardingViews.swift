import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: Int = 0
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var selectedLevel: SkaterLevel? = nil
    @State private var selectedTricks: Set<String> = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Capsule()
                            .fill(i <= currentStep ? Color(hex: "#87FF00") : Color.white.opacity(0.2))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)
                
                // Content
                TabView(selection: $currentStep) {
                    OnboardingStep1(name: $name, age: $age, onNext: {
                        withAnimation { currentStep = 1 }
                    })
                    .tag(0)
                    
                    OnboardingStep2(selectedLevel: $selectedLevel, onNext: {
                        withAnimation { currentStep = 2 }
                    }, onBack: {
                        withAnimation { currentStep = 0 }
                    })
                    .tag(1)
                    
                    OnboardingStep3(selectedTricks: $selectedTricks, onFinish: {
                        completeOnboarding()
                    }, onBack: {
                        withAnimation { currentStep = 1 }
                    })
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
    
    func completeOnboarding() {
        let ageInt = Int(age) ?? 18
        let user = UserProfile(
            name: name.isEmpty ? "Skater" : name,
            age: ageInt,
            level: selectedLevel ?? .amateur,
            unlockedTricks: Array(selectedTricks)
        )
        appState.saveUser(user)
        withAnimation {
            appState.appPhase = .welcome
        }
    }
}

// MARK: - Step 1: User Info


// MARK: - Step 2: Level Selection


struct LevelCard: View {
    let level: SkaterLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "#87FF00") : Color.white.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: level.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .black : .white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.localizedName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(level.description)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#87FF00"))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex: "#87FF00") : Color.white.opacity(0.1), lineWidth: 1.5)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Step 3: Tricks Selection


