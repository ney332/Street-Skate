//
//  ProgressView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var sessions: [TrainingSession] = []
    @State private var selectedWeekOffset: Int = 0
    
    var user: UserProfile? { appState.currentUser }
    
    // Weekly data (last 7 days)
    var weeklyData: [DayData] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { offset -> DayData in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
            return DayData(
                date: date,
                calories: daySessions.reduce(0) { $0 + $1.calories },
                distanceKm: daySessions.reduce(0) { $0 + $1.distanceKm },
                sessionCount: daySessions.count
            )
        }
    }
    
    var weeklyTotals: (calories: Double, distanceKm: Double, sessions: Int) {
        (weeklyData.reduce(0) { $0 + $1.calories }, weeklyData.reduce(0) { $0 + $1.distanceKm }, weeklyData.reduce(0) { $0 + $1.sessionCount })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // XP Level card
                        if let u = user {
                            XPLevelCard(user: u)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
                        
                        // Weekly totals banner
                        WeeklyBanner(totals: weeklyTotals)
                            .padding(.horizontal, 20)
                        
                        // Calories bar chart
                        WeeklyBarChart(
                            title: "Calories Burned",
                            unit: "kcal",
                            values: weeklyData.map { $0.calories },
                            dates: weeklyData.map { $0.date },
                            color: Color(hex: "#FF6B35"),
                            maxGoal: 500
                        )
                        .padding(.horizontal, 20)
                        
                        // Distance bar chart
                        WeeklyBarChart(
                            title: "Distance",
                            unit: "km",
                            values: weeklyData.map { $0.distanceKm },
                            dates: weeklyData.map { $0.date },
                            color: Color(hex: "#2196F3"),
                            maxGoal: 5
                        )
                        .padding(.horizontal, 20)
                        
                        // Sessions per day
                        WeeklyBarChart(
                            title: "Sessions",
                            unit: "sessions",
                            values: weeklyData.map { Double($0.sessionCount) },
                            dates: weeklyData.map { $0.date },
                            color: Color(hex: "#4CAF50"),
                            maxGoal: 2
                        )
                        .padding(.horizontal, 20)
                        
                        // Trick progression
                        TrickProgressSection(user: user)
                            .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 40)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Progress")
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
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "trainingSessions"),
               let saved = try? JSONDecoder().decode([TrainingSession].self, from: data) {
                sessions = saved
            }
        }
    }
}

// MARK: - Data Models
struct DayData {
    let date: Date
    let calories: Double
    let distanceKm: Double
    let sessionCount: Int
}

// MARK: - Weekly Banner
struct WeeklyBanner: View {
    let totals: (calories: Double, distanceKm: Double, sessions: Int)
    
    var body: some View {
        HStack(spacing: 0) {
            WeeklyBannerStat(value: "\(Int(totals.calories))", unit: "kcal", label: "This Week")
            Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 40)
            WeeklyBannerStat(value: String(format: "%.1f", totals.distanceKm), unit: "km", label: "Distance")
            Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 40)
            WeeklyBannerStat(value: "\(totals.sessions)", unit: "", label: "Sessions")
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
}

struct WeeklyBannerStat: View {
    let value: String
    let unit: String
    let label: String
    
    var body: some View {
        VStack(spacing: 3) {
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                }
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weekly Bar Chart
struct WeeklyBarChart: View {
    let title: String
    let unit: String
    let values: [Double]
    let dates: [Date]
    let color: Color
    let maxGoal: Double
    
    var maxValue: Double { max(values.max() ?? 0, maxGoal * 0.5, 1) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                // Goal indicator
                HStack(spacing: 4) {
                    Circle().fill(color.opacity(0.5)).frame(width: 6, height: 6)
                    Text("Goal: \(maxGoal < 10 ? String(format: "%.0f", maxGoal) : "\(Int(maxGoal))") \(unit)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.35))
                }
            }
            
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<min(values.count, dates.count), id: \.self) { i in
                    VStack(spacing: 5) {
                        // Value label on top of bar
                        if values[i] > 0 {
                            Text(values[i] < 10 ? String(format: "%.1f", values[i]) : "\(Int(values[i]))")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(color)
                        } else {
                            Text("0").font(.system(size: 9)).foregroundColor(Color.white.opacity(0.2))
                        }
                        
                        // Bar
                        GeometryReader { _ in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(
                                        values[i] > 0
                                        ? LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .frame(height: max(4, CGFloat(values[i] / maxValue) * 80))
                            }
                        }
                        .frame(height: 80)
                        
                        // Day label
                        Text(dayLabel(for: dates[i]))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isToday(dates[i]) ? color : Color.white.opacity(0.35))
                    }
                }
            }
            
            // Goal line indicator
            HStack(spacing: 6) {
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: 20, height: 1)
                    .overlay(
                        Rectangle().fill(color.opacity(0.3)).frame(height: 1)
                            .overlay(
                                Rectangle().fill(color).frame(width: 6, height: 1).offset(x: -7)
                            )
                    )
                Text("Daily goal")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.3))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
    
    func dayLabel(for date: Date) -> String {
        if isToday(date) { return "Today" }
        return date.formatted(.dateTime.weekday(.abbreviated))
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Trick Progress Section
struct TrickProgressSection: View {
    let user: UserProfile?
    
    var categoryBreakdown: [(category: TrickCategory, unlocked: Int, total: Int)] {
        TrickCategory.allCases.map { cat in
            let total = SkateTrick.allTricks.filter { $0.category == cat }.count
            let unlocked = SkateTrick.allTricks.filter { $0.category == cat && (user?.unlockedTricks.contains($0.name) ?? false) }.count
            return (cat, unlocked, total)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Trick Progress")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(categoryBreakdown, id: \.category) { item in
                let progress = item.total > 0 ? Double(item.unlocked) / Double(item.total) : 0
                
                VStack(spacing: 6) {
                    HStack {
                        Text(item.category.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(item.unlocked)/\(item.total)")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#87FF00"))
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [Color(hex: "#87FF00"), Color(hex: "#87FF00")], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}
