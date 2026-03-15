//
//  StreakService.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI
import Foundation
import Combine
// MARK: - Streak Service
class StreakService: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastSessionDate: Date? = nil

    init() { load() }

    func updateStreak(with sessions: [TrainingSession]) {
        guard !sessions.isEmpty else { return }

        let calendar = Calendar.current
        let sortedDates = Set(sessions.map { calendar.startOfDay(for: $0.date) }).sorted(by: >)

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if date < checkDate {
                break
            }
        }

        currentStreak = streak
        longestStreak = max(longestStreak, streak)
        lastSessionDate = sessions.map { $0.date }.max()
        save()
    }

    var isActiveToday: Bool {
        guard let last = lastSessionDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func save() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(longestStreak, forKey: "longestStreak")
        if let date = lastSessionDate {
            UserDefaults.standard.set(date, forKey: "lastSessionDate")
        }
    }

    func load() {
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        longestStreak = UserDefaults.standard.integer(forKey: "longestStreak")
        lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date
    }
}

// MARK: - Streak Card View
struct StreakCard: View {
    @ObservedObject var streakService: StreakService
    @State private var flamePulse = false

    var body: some View {
        HStack(spacing: 16) {
            // Flame icon
            ZStack {
                Circle()
                    .fill(streakService.currentStreak > 0
                          ? Color(hex: "#FF6B35").opacity(0.2)
                          : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                    .scaleEffect(flamePulse ? 1.1 : 1.0)
                    .animation(
                        streakService.currentStreak > 0
                        ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                        : .default,
                        value: flamePulse
                    )

                Image(systemName: streakService.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 26))
                    .foregroundColor(streakService.currentStreak > 0 ? Color(hex: "#FF6B35") : Color.white.opacity(0.2))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(streakService.currentStreak) day streak")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text(streakService.currentStreak == 0
                     ? "Start your streak today!"
                     : streakService.isActiveToday
                        ? "✓ Skated today"
                        : "⚠️ Skate today to keep it!")
                    .font(.system(size: 13))
                    .foregroundColor(
                        streakService.isActiveToday ? Color(hex: "#4CAF50")
                        : streakService.currentStreak > 0 ? Color(hex: "#FF9800")
                        : Color.white.opacity(0.4)
                    )
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(streakService.longestStreak)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "#FFD700"))
                Text("best")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.35))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    streakService.currentStreak > 0
                    ? Color(hex: "#FF6B35").opacity(0.08)
                    : Color.white.opacity(0.04)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            streakService.currentStreak > 0
                            ? Color(hex: "#FF6B35").opacity(0.25)
                            : Color.white.opacity(0.07),
                            lineWidth: 1
                        )
                )
        )
        .onAppear { flamePulse = streakService.currentStreak > 0 }
        .onChange(of: streakService.currentStreak) { _, v in flamePulse = v > 0 }
    }
}

// MARK: - Weekly Dot Calendar
struct WeeklyCalendarStrip: View {
    let sessions: [TrainingSession]

    var activeDays: Set<String> {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return Set(sessions.map { fmt.string(from: $0.date) })
    }

    func dayKey(_ offset: Int) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
        return fmt.string(from: date)
    }

    func dayLabel(_ offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
        return date.formatted(.dateTime.weekday(.abbreviated))
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach((0..<7).reversed(), id: \.self) { offset in
                let key = dayKey(offset)
                let active = activeDays.contains(key)
                let isToday = offset == 0

                VStack(spacing: 6) {
                    Text(dayLabel(offset))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isToday ? Color(hex: "#FFD700") : Color.white.opacity(0.35))

                    ZStack {
                        Circle()
                            .fill(active
                                  ? (isToday ? Color(hex: "#FFD700") : Color(hex: "#FF6B35"))
                                  : Color.white.opacity(0.07))
                            .frame(width: 28, height: 28)

                        if active {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isToday ? .black : .white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }
}
