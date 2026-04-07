//
//  StartTrainingCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct StartTrainingCard: View {
    let onStart: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onStart) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#0F0F0F")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
           
                // containerRelativeFrame()
                .cornerRadius(24)
                
                // Glow dot
//                Circle()
//                    .fill(Color(hex: "#FFD700").opacity(0.2))
//                    .frame(width: 120, height: 120)
//                    .blur(radius: 30)
//                    .offset(x: 80, y: -30)
                
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.white).opacity(0.1))
                                .frame(width: 60, height: 60)
                            Image(systemName: "play.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color("verde"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Session".localized)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Choose tricks and hit the road".localized)
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        
                        HStack(spacing: 16) {
                            InfoPill(icon: "timer", text: "Track time".localized)
                            InfoPill(icon: "location.fill", text: "GPS route".localized)
                        }
                    }
                    Spacer()
                }
                .padding(24)
            }
            .frame(height: 200)
            .shadow(color: Color.white.opacity(0.2), radius: 1, y: 1)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
