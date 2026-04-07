//
//  SessionMetricsPanel.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct SessionMetricsPanel: View {
    @ObservedObject var sessionVM: SessionViewModel
    var pushCount: Int = 0
    let onStart: () -> Void
    let onEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Metrics grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    SessionMetric(
                        value: sessionVM.formattedDuration,
                        label: "Duration".localized,
                        icon: "timer"
                    )
                    SessionMetric(
                        value: String(format: "%.2f", sessionVM.distanceKm),
                        label: "km",
                        icon: "arrow.triangle.swap"
                    )
                }
                HStack(spacing: 16) {
                    SessionMetric(
                        value: "\(Int(sessionVM.calories))",
                        label: "Calories".localized,
                        icon: "flame.fill"
                    )
                    SessionMetric(
                        value: "\(pushCount > 0 ? pushCount : sessionVM.pushCount)",
                        label: "Push".localized,
                        icon: "arrow.forward.circle"
                    )
                }
            }
            .padding(20)
            
            Divider().background(Color.white.opacity(0.1))
            
            // Action buttons
            HStack(spacing: 12) {
                if !sessionVM.isRunning && sessionVM.startTime == nil {
                    Button(action: onStart) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Start".localized)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "#87FF00"), Color(hex: "#87FF00")], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                    }
                    .disabled(sessionVM.isRunning || sessionVM.startTime != nil)
                } else {
                    Button(action: {
                        if sessionVM.isRunning { sessionVM.pauseSession() } else { sessionVM.resumeSession() }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: sessionVM.isRunning ? "pause.fill" : "play.fill")
                            Text(sessionVM.isRunning ? "Pause".localized : "Resume".localized)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    Button(action: onEnd) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text("End Session".localized)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex: "#87FF00")], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                    }
                }
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 12)
        .padding(.bottom, 30)
    }
}
