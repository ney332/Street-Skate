//
//  OnboardingStep3.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

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
