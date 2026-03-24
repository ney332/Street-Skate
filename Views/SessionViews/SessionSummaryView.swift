//
//  SessionSummaryView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI
import MapKit

/// Animated post-session summary screen shown after ending a training session.
/// Inspired by Apple Fitness+ end-of-workout summary.
struct SessionSummaryView: View {
    let session: TrainingSession
    let newAchievements: [Achievement]
    let onDismiss: () -> Void

    @State private var appear = false
    @State private var ringProgress: Double = 0
    @State private var showMetrics = false
    @State private var showAchievements = false
    @State private var confettiTrigger = false

    var durationText: String {
        let t = Int(session.duration)
        let h = t / 3600, m = (t % 3600) / 60, s = t % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }

    var xpEarned: Int { Int(session.distanceKm * 10) + Int(session.duration / 60) * 2 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background glow
            RadialGradient(
                colors: [Color(hex: "#87FF00").opacity(0.12), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "#87FF00"))
                            .scaleEffect(appear ? 1 : 0.3)
                            .opacity(appear ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: appear)

                        Text("Session Complete!")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 12)
                            .animation(.easeOut(duration: 0.5).delay(0.25), value: appear)

                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.4))
                            .opacity(appear ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.35), value: appear)
                    }
                    .padding(.top, 64)
                    .padding(.bottom, 36)

                    // Activity ring
                    ZStack {
                        ActivityRingView(
                            progress: ringProgress,
                            ringColor: Color(hex: "#FFD700"),
                            size: 160,
                            lineWidth: 18
                        )

                        VStack(spacing: 4) {
                            Text("+\(xpEarned)")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "#FFD700"))
                            Text("XP earned")
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.4), value: appear)

                    // Metrics grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        SummaryMetric(
                            value: durationText, label: "Duration",
                            icon: "timer", color: Color(hex: "#2196F3"), delay: 0.5
                        )
                        SummaryMetric(
                            value: String(format: "%.2f km", session.distanceKm), label: "Distance",
                            icon: "figure.skating", color: Color(hex: "#4CAF50"), delay: 0.6
                        )
                        SummaryMetric(
                            value: "\(Int(session.calories)) kcal", label: "Calories",
                            icon: "flame.fill", color: Color(hex: "#FF6B35"), delay: 0.7
                        )
                        SummaryMetric(
                            value: "\(session.pushCount)", label: "Remadas",
                            icon: "arrow.forward.circle", color: Color(hex: "#9C27B0"), delay: 2.0
                        )
                    }
                    .padding(.horizontal, 24)
                    .opacity(showMetrics ? 1 : 0)
                    .offset(y: showMetrics ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.45), value: showMetrics)

                    // Tricks practiced
                    if !session.tricksAttempted.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tricks Practiced")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            FlowLayout(spacing: 8) {
                                ForEach(session.tricksAttempted, id: \.self) { trick in
                                    Text(trick)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(hex: "#FFD700"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "#FFD700").opacity(0.12))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(hex: "#FFD700").opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .opacity(showMetrics ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.9), value: showMetrics)
                    }

                    // New achievements
                    if !newAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Color(hex: "#FFD700"))
                                Text("Achievements Unlocked!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            ForEach(newAchievements) { achievement in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#FFD700").opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: achievement.icon)
                                            .font(.system(size: 18))
                                            .foregroundColor(Color(hex: "#FFD700"))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(achievement.title)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                        Text(achievement.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Text("+\(achievement.xpReward) XP")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(hex: "#FFD700"))
                                }
                                .padding(12)
                                .background(Color(hex: "#FFD700").opacity(0.06))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#FFD700").opacity(0.2), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .opacity(showAchievements ? 1 : 0)
                        .offset(y: showAchievements ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(1.0), value: showAchievements)
                    }

                    // Done button
                    Button(action: onDismiss) {
                        HStack(spacing: 10) {
                            Text("Done")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#87FF00")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: Color(hex: "#FFD700").opacity(0.3), radius: 16, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 60)
                    .opacity(showMetrics ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(1.1), value: showMetrics)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            appear = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    ringProgress = min(Double(xpEarned) / 500.0, 1.0)
                }
                showMetrics = true
                showAchievements = true
            }
        }
    }
}

// MARK: - Activity Ring View
struct ActivityRingView: View {
    let progress: Double
    let ringColor: Color
    let size: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(ringColor.opacity(0.15), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [ringColor, ringColor.opacity(0.6), ringColor],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .shadow(color: ringColor.opacity(0.4), radius: 8)
                .animation(.easeInOut(duration: 1.2), value: progress)

            // End cap glow
            if progress > 0.02 {
                let angle = Angle(degrees: progress * 360 - 90)
                let radius = size / 2
                let x = cos(angle.radians) * radius
                let y = sin(angle.radians) * radius
                Circle()
                    .fill(ringColor)
                    .frame(width: lineWidth, height: lineWidth)
                    .shadow(color: ringColor, radius: 6)
                    .offset(x: x, y: y)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Summary Metric Card
struct SummaryMetric: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let delay: Double

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(appeared ? 1 : 0.85)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - FlowLayout (wrapping HStack)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, maxHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                y += maxHeight + spacing; x = 0; maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        return CGSize(width: width, height: y + maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, maxHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += maxHeight + spacing; x = bounds.minX; maxHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}
