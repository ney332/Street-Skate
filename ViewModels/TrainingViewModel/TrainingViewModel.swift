//
//  TrainingViewModel.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI
import Combine

class TrainingViewModel: ObservableObject {
    @Published var recentSessions: [TrainingSession] = []
    @Published var todayCalories: Double = 0
    @Published var todayDistanceKm: Double = 0
    @Published var todayPushCount: Int = 0
    @Published var activityByHour: [Int: Double] = [:]
    
    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "trainingSessions"),
           let sessions = try? JSONDecoder().decode([TrainingSession].self, from: data) {
            recentSessions = sessions.sorted { $0.date > $1.date }
            calculateTodayMetrics()
        }
    }
    
    func saveSession(_ session: TrainingSession, user: inout UserProfile?) {
        recentSessions.insert(session, at: 0)
        if let data = try? JSONEncoder().encode(recentSessions) {
            UserDefaults.standard.set(data, forKey: "trainingSessions")
        }
        
        // Update user stats
        user?.totalSessions += 1
        user?.totalDistanceKm += session.distanceKm
        user?.totalCalories += session.calories
        user?.xp += Int(session.distanceKm * 10) + Int(session.duration / 60) * 2
        
        calculateTodayMetrics()
    }
    
    private func calculateTodayMetrics() {
        let calendar = Calendar.current
        let todaySessions = recentSessions.filter { calendar.isDateInToday($0.date) }
        
        todayCalories = todaySessions.reduce(0) { $0 + $1.calories }
        todayDistanceKm = todaySessions.reduce(0) { $0 + $1.distanceKm }
        todayPushCount = todaySessions.reduce(0) { $0 + $1.pushCount }
        
        // Build activity by hour
        var byHour: [Int: Double] = [:]
        for session in todaySessions {
            let hour = calendar.component(.hour, from: session.date)
            byHour[hour] = (byHour[hour] ?? 0) + min(session.distanceKm / 2, 1.0)
        }
        activityByHour = byHour
    }

    func metricEntries(for metric: TrainingMetricType, days: Int = 7) -> [MetricBarEntry] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        return (0..<days).compactMap { offset -> MetricBarEntry? in
            guard let day = calendar.date(byAdding: .day, value: -(days - 1 - offset), to: startOfToday) else {
                return nil
            }

            let nextDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let sessionsForDay = recentSessions.filter { $0.date >= day && $0.date < nextDay }

            let value: Double
            switch metric {
            case .calories:
                value = sessionsForDay.reduce(0) { $0 + $1.calories }
            case .distance:
                value = sessionsForDay.reduce(0) { $0 + $1.distanceKm }
            case .pushes:
                value = Double(sessionsForDay.reduce(0) { $0 + $1.pushCount })
            case .activity:
                value = sessionsForDay.reduce(0) { $0 + ($1.duration / 60) }
            }

            return MetricBarEntry(date: day, value: value)
        }
    }

    func totalValue(for metric: TrainingMetricType, days: Int = 7) -> Double {
        metricEntries(for: metric, days: days).reduce(0) { $0 + $1.value }
    }

    func averageValue(for metric: TrainingMetricType, days: Int = 7) -> Double {
        let entries = metricEntries(for: metric, days: days)
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0) { $0 + $1.value } / Double(entries.count)
    }
}
