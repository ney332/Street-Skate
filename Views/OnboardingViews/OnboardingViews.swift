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
struct OnboardingStep1: View {
    @Binding var name: String
    @Binding var age: String
    var onNext: () -> Void
    
    @FocusState private var focusedField: Field?
    enum Field { case name, age }
    
    var isValid: Bool { !name.isEmpty && !age.isEmpty }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who are you?")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Tell us about yourself to get started")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                
                VStack(spacing: 16) {
                    FloatingTextField(placeholder: "Your name", text: $name, icon: "person.fill")
                        .focused($focusedField, equals: .name)
                    
                    FloatingTextField(placeholder: "Your age", text: $age, icon: "calendar", keyboardType: .numberPad)
                        .focused($focusedField, equals: .age)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                focusedField = nil
                onNext()
            }) {
                PrimaryButton(title: "Next", isEnabled: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Step 2: Level Selection
struct OnboardingStep2: View {
    @Binding var selectedLevel: SkaterLevel?
    var onNext: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Level")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("How experienced are you on a board?")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .padding(.horizontal, 32)
                
                VStack(spacing: 12) {
                    ForEach(SkaterLevel.allCases, id: \.self) { level in
                        LevelCard(
                            level: level,
                            isSelected: selectedLevel == level,
                            onTap: { selectedLevel = level }
                        )
                    }
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    SecondaryButton(title: "Back")
                }
                
                Button(action: onNext) {
                    PrimaryButton(title: "Next", isEnabled: selectedLevel != nil)
                }
                .disabled(selectedLevel == nil)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}

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
                    Text(level.rawValue)
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
struct OnboardingStep3: View {
    @Binding var selectedTricks: Set<String>
    var onFinish: () -> Void
    var onBack: () -> Void
    
    @State private var visibleTricks: [SkateTrick] = []
    @State private var allTricks: [SkateTrick] = SkateTrick.allTricks
    @State private var removingTricks: Set<UUID> = []
    
    let columns = [GridItem(.adaptive(minimum: 130), spacing: 12)]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Know these?")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Tap tricks you can already do — they'll unlock!")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Selected count
            if !selectedTricks.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#87FF00"))
                    Text("\(selectedTricks.count) tricks unlocked")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#87FF00"))
                }
                .padding(.top, 12)
            }
            
            // Floating trick cards
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(visibleTricks) { trick in
                        TrickBubble(
                            trick: trick,
                            isRemoving: removingTricks.contains(trick.id),
                            onTap: { handleTrickTap(trick) }
                        )
                    }
                }
                .padding(24)
            }
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    SecondaryButton(title: "Back")
                }
                
                Button(action: onFinish) {
                    PrimaryButton(title: "Let's Go! 🛹", isEnabled: true)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .onAppear { loadInitialTricks() }
    }
    
    func loadInitialTricks() {
        visibleTricks = Array(allTricks.prefix(12))
    }
    
    func handleTrickTap(_ trick: SkateTrick) {
        selectedTricks.insert(trick.name)
        
        // Remove with animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            removingTricks.insert(trick.id)
        }
        
        // After animation, replace with new trick
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let idx = visibleTricks.firstIndex(where: { $0.id == trick.id }) {
                let remaining = allTricks.filter { t in
                    !visibleTricks.contains(t) && !selectedTricks.contains(t.name)
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    removingTricks.remove(trick.id)
                    if let newTrick = remaining.randomElement() {
                        visibleTricks[idx] = newTrick
                    } else {
                        visibleTricks.remove(at: idx)
                    }
                }
            }
        }
    }
}

struct TrickBubble: View {
    let trick: SkateTrick
    let isRemoving: Bool
    let onTap: () -> Void
    
    var difficultyColor: Color {
        switch trick.difficulty {
        case .beginner: return Color(hex: "#4CAF50")
        case .intermediate: return Color(hex: "#2196F3")
        case .advanced: return Color(hex: "#FF9800")
        case .expert: return Color(hex: "#F44336")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(trick.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(trick.difficulty.rawValue.capitalized)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(difficultyColor)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(difficultyColor.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isRemoving ? 0.1 : 1.0)
        .opacity(isRemoving ? 0 : 1)
        .rotationEffect(isRemoving ? .degrees(180) : .degrees(0))
    }
}
