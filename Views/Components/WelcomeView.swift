//
//  WelcomeView.swift
//  SkateAppp
//
//  Created by Lorran on 17/03/26.
//


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
                        .fill(Color(hex: "#87FF00").opacity(0.15))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#87FF00"), Color(hex: "#87FF00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 104, height: 104)
                            .shadow(color: Color(hex: "#87FF00").opacity(0.4), radius: 24)
                        
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
                            colors: [Color(hex: "#87FF00"), Color(hex: "#87FF00")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: Color(hex: "#87FF00").opacity(0.35), radius: 16, y: 6)
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
