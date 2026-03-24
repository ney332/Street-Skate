//
//  TrickLogEntry.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Trick Log Entry
struct TrickLogEntry: Identifiable, Codable {
    let id: UUID
    let trickName: String
    let date: Date
    let sessionId: UUID?
    let status: TrickLogStatus
    let note: String

    init(id: UUID = UUID(), trickName: String, date: Date = Date(),
         sessionId: UUID? = nil, status: TrickLogStatus = .landed, note: String = "") {
        self.id = id
        self.trickName = trickName
        self.date = date
        self.sessionId = sessionId
        self.status = status
        self.note = note
    }
}

enum TrickLogStatus: String, Codable, CaseIterable {
    case landed    = "Landed"
    case almost    = "Almost"
    case learning  = "Learning"
    case firstTime = "First Time!"

    var icon: String {
        switch self {
        case .landed:    return "checkmark.circle.fill"
        case .almost:    return "circle.dotted"
        case .learning:  return "arrow.clockwise"
        case .firstTime: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .landed:    return Color(hex: "#4CAF50")
        case .almost:    return Color(hex: "#FF9800")
        case .learning:  return Color(hex: "#2196F3")
        case .firstTime: return Color(hex: "#87FF00")
        }
    }
}

// MARK: - Trick Log Service
class TrickLogService: ObservableObject {
    static let shared = TrickLogService()
    @Published var entries: [TrickLogEntry] = []

    private init() { load() }

    func log(trick: String, status: TrickLogStatus, sessionId: UUID? = nil, note: String = "") {
        let entry = TrickLogEntry(trickName: trick, sessionId: sessionId, status: status, note: note)
        entries.insert(entry, at: 0)
        save()
    }

    func entries(for trick: String) -> [TrickLogEntry] {
        entries.filter { $0.trickName == trick }
    }

    func recentEntries(limit: Int = 20) -> [TrickLogEntry] {
        Array(entries.prefix(limit))
    }

    func landingRate(for trick: String) -> Double {
        let e = entries(for: trick)
        guard !e.isEmpty else { return 0 }
        let landed = e.filter { $0.status == .landed || $0.status == .firstTime }.count
        return Double(landed) / Double(e.count)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: "trickLog")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "trickLog"),
           let saved = try? JSONDecoder().decode([TrickLogEntry].self, from: data) {
            entries = saved
        }
    }

    func reset() {
        entries = []
        UserDefaults.standard.removeObject(forKey: "trickLog")
    }
}
