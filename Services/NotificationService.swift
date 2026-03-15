//
//  NotificationService.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//
import UserNotifications
import Foundation

class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - Request Permission
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule Daily Reminder
    func scheduleDailyReminder(hour: Int = 17, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_skate_reminder"])

        let messages = [
            "🛹 Time to shred! Your board is waiting.",
            "🔥 Don't break the streak — hit the streets!",
            "⚡ Your skate session won't happen by itself.",
            "🏆 Every push counts. Go skate!",
            "🌆 Perfect weather to practice that trick.",
        ]

        let content = UNMutableNotificationContent()
        content.title = "Street Skate"
        content.body = messages.randomElement() ?? messages[0]
        content.sound = .default
        content.badge = 1
        content.launchImageName = "icon"

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_skate_reminder", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Achievement Unlocked Notification
    func sendAchievementNotification(title: String, description: String) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Achievement Unlocked!"
        content.body = "\(title) — \(description)"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("achievement"))
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Session Milestone (in-session)
    func sendMilestoneNotification(km: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🛹 Milestone!"
        content.body = String(format: "You've skated %.0f km in this session. Keep pushing!", km)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "milestone_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Schedule Streak Reminder
    func scheduleStreakWarning() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak_warning"])

        let content = UNMutableNotificationContent()
        content.title = "⚠️ Streak at risk!"
        content.body = "You haven't skated today. Don't break your streak!"
        content.sound = .default

        // Fires at 20:00 if no session logged today
        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_warning", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Cancel All
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
