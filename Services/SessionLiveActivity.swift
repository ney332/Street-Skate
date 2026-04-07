// SessionLiveActivity.swift
// Street Skate – ActivityAttributes da Live Activity
//
// ⚠️  LOCALIZAÇÃO CORRETA: Street Skate/Services/SessionLiveActivity.swift
//
// Este arquivo fica na pasta Services/ para que o target principal (SkateAppp)
// o compile automaticamente via fileSystemSynchronizedGroups.
// O target da extension (StreetSkateWidgetExtensionExtension) também precisa
// deste arquivo — adicione-o via File Inspector > Target Membership.

import ActivityKit
import Foundation

struct SkateSessionAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        var isRunning: Bool
        var duration: TimeInterval
        var distanceKm: Double
        var calories: Double
        var pushCount: Int
        var speedKmh: Double

        var formattedDuration: String {
            let total = Int(duration)
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            return h > 0
                ? String(format: "%d:%02d:%02d", h, m, s)
                : String(format: "%02d:%02d", m, s)
        }

        var formattedDistance: String {
            String(format: "%.2f", distanceKm)
        }

        var formattedSpeed: String {
            String(format: "%.1f", speedKmh)
        }
    }

    var sessionStartDate: Date
    var userName: String
}
