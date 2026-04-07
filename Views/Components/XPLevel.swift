//
//  XPLevel.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI
import Foundation

// MARK: - XP Level System
struct XPLevel {
    let level: Int
    let title: String
    let icon: String
    let minXP: Int
    let maxXP: Int
    let accentColor: Color

    var progress: Double { 0 }  // computed per-user below

    static func level(for xp: Int) -> XPLevel {
        return all.last(where: { xp >= $0.minXP }) ?? all[0]
    }

    static func progress(for xp: Int) -> Double {
        let current = level(for: xp)
        let span = current.maxXP - current.minXP
        guard span > 0 else { return 1.0 }
        return Double(xp - current.minXP) / Double(span)
    }

    static let all: [XPLevel] = [
        XPLevel(level: 1, title: "Grom",          icon: "figure.walk",          minXP: 0,     maxXP: 200,   accentColor: Color(hex: "#9E9E9E")),
        XPLevel(level: 2, title: "Rookie",         icon: "skateboard",           minXP: 200,   maxXP: 500,   accentColor: Color(hex: "#4CAF50")),
        XPLevel(level: 3, title: "Shredder",       icon: "figure.skating",       minXP: 500,   maxXP: 1000,  accentColor: Color(hex: "#2196F3")),
        XPLevel(level: 4, title: "Street Rat",     icon: "road.lanes",           minXP: 1000,  maxXP: 2000,  accentColor: Color(hex: "#FF9800")),
        XPLevel(level: 5, title: "Ledge Wizard",   icon: "wand.and.stars",       minXP: 2000,  maxXP: 3500,  accentColor: Color(hex: "#9C27B0")),
        XPLevel(level: 6, title: "Park Rat",       icon: "circle.dashed",        minXP: 3500,  maxXP: 5000,  accentColor: Color(hex: "#00BCD4")),
        XPLevel(level: 7, title: "Tech Master",    icon: "star.fill",            minXP: 5000,  maxXP: 8000,  accentColor: Color(hex: "#FF6B35")),
        XPLevel(level: 8, title: "Pro Skater",     icon: "crown.fill",           minXP: 8000,  maxXP: 12000, accentColor: Color(hex: "#87FF00")),
        XPLevel(level: 9, title: "Legend",         icon: "bolt.fill",            minXP: 12000, maxXP: 20000, accentColor: Color(hex: "#E91E63")),
        XPLevel(level: 10, title: "S.K.A.T.E God", icon: "sparkles",            minXP: 20000, maxXP: 99999, accentColor: Color(hex: "#FF1744")),
    ]
}

// MARK: - XP Level Card
struct XPLevelCard: View {
    let user: UserProfile
    @State private var progressAnimated: Double = 0

    var xpLevel: XPLevel { XPLevel.level(for: user.xp) }
    var xpProgress: Double { XPLevel.progress(for: user.xp) }
    var xpToNext: Int { xpLevel.maxXP - user.xp }

    var body: some View {
        VStack(spacing: 0) {
            // Top section with level info
            HStack(spacing: 16) {
                // Level badge
                ZStack {
                    Circle()
                        .fill(xpLevel.accentColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Circle()
                        .stroke(xpLevel.accentColor.opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 60)
                    VStack(spacing: 1) {
                        Image(systemName: xpLevel.icon)
                            .font(.system(size: 18))
                            .foregroundColor(xpLevel.accentColor)
                        Text("Lv.\(xpLevel.level)")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(xpLevel.accentColor)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(xpLevel.title)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 6) {
                        Text("\(user.xp) XP")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(xpLevel.accentColor)
                        Text("·")
                            .foregroundColor(Color.white.opacity(0.2))
                        Text("\(xpToNext) XP to next")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                }

                Spacer()

                // Next level preview
                if xpLevel.level < 10 {
                    VStack(spacing: 3) {
                        Image(systemName: XPLevel.all[xpLevel.level].icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.2))
                        Text("Next")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.2))
                        Text(XPLevel.all[xpLevel.level].title)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.2))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            // Progress bar with level labels
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.07))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [xpLevel.accentColor, xpLevel.accentColor.opacity(0.7)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progressAnimated, height: 8)
                            .shadow(color: xpLevel.accentColor.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Lv.\(xpLevel.level)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(xpLevel.accentColor.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.0f%%", xpProgress * 100))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(xpLevel.accentColor.opacity(0.7))
                    Spacer()
                    Text("Lv.\(xpLevel.level + 1)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.25))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(xpLevel.accentColor.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(xpLevel.accentColor.opacity(0.2), lineWidth: 1.5)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                progressAnimated = xpProgress
            }
        }
        .onChange(of: user.xp) { _, _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                progressAnimated = xpProgress
            }
        }
    }
}

// MARK: - All Levels View
struct AllLevelsView: View {
    let userXP: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(XPLevel.all, id: \.level) { lvl in
                            let isUnlocked = userXP >= lvl.minXP
                            let isCurrent = XPLevel.level(for: userXP).level == lvl.level

                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(isUnlocked ? lvl.accentColor.opacity(0.2) : Color.white.opacity(0.05))
                                        .frame(width: 48, height: 48)
                                    if isUnlocked {
                                        Circle()
                                            .stroke(lvl.accentColor.opacity(0.4), lineWidth: 1.5)
                                            .frame(width: 48, height: 48)
                                    }
                                    Image(systemName: lvl.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(isUnlocked ? lvl.accentColor : Color.white.opacity(0.15))
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 8) {
                                        Text("Lv.\(lvl.level) · \(lvl.title)")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(isUnlocked ? .white : Color.white.opacity(0.3))
                                        if isCurrent {
                                            Text("YOU ARE HERE")
                                                .font(.system(size: 9, weight: .black))
                                                .foregroundColor(lvl.accentColor)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(lvl.accentColor.opacity(0.15))
                                                .cornerRadius(4)
                                        }
                                    }
                                    Text("\(lvl.minXP) – \(lvl.maxXP < 99999 ? "\(lvl.maxXP)" : "∞") XP")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.white.opacity(0.35))
                                }

                                Spacer()

                                if isUnlocked {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(lvl.accentColor)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(isCurrent ? lvl.accentColor.opacity(0.08) : Color.white.opacity(isUnlocked ? 0.05 : 0.02))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isCurrent ? lvl.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("All Levels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "#87FF00"))
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
