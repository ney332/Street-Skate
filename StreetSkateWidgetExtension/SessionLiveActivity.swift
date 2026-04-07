
import Foundation
import ActivityKit
import Combine

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


@MainActor
final class LiveActivityService: ObservableObject {

    static let shared = LiveActivityService()
    private init() {}

    // Referência para a activity ativa
    private var activity: Activity<SkateSessionAttributes>?
    @Published private(set) var lastDebugMessage: String = ""

    private func log(_ message: String) {
        lastDebugMessage = message
        print("[LiveActivity] \(message)")
    }

    // MARK: - Iniciar

    func start(userName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            log("Atividades ao vivo desabilitadas no dispositivo/app.")
            return
        }

        // Encerra qualquer activity anterior (segurança)
        endAll()

        let attributes = SkateSessionAttributes(
            sessionStartDate: Date(),
            userName: userName
        )

        let initialState = SkateSessionAttributes.ContentState(
            isRunning: true,
            duration: 0,
            distanceKm: 0,
            calories: 0,
            pushCount: 0,
            speedKmh: 0
        )

        let content = ActivityContent(
            state: initialState,
            staleDate: Date().addingTimeInterval(60 * 60 * 4) // expira em 4h
        )

        do {
            activity = try Activity<SkateSessionAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil // local-only (sem APNS)
            )
            if let activity {
                log("Live Activity iniciada com sucesso. id=\(activity.id)")
            } else {
                log("Activity.request retornou sem instância ativa.")
            }
        } catch {
            log("Erro ao iniciar: \(error.localizedDescription)")
        }
    }

    // MARK: - Atualizar

    func update(
        isRunning: Bool,
        duration: TimeInterval,
        distanceKm: Double,
        calories: Double,
        pushCount: Int,
        speedKmh: Double
    ) {
        guard let activity else {
            log("Update ignorado: nenhuma Live Activity ativa.")
            return
        }

        let newState = SkateSessionAttributes.ContentState(
            isRunning: isRunning,
            duration: duration,
            distanceKm: distanceKm,
            calories: calories,
            pushCount: pushCount,
            speedKmh: speedKmh
        )

        let content = ActivityContent(
            state: newState,
            staleDate: Date().addingTimeInterval(60 * 60 * 4)
        )

        Task {
            await activity.update(content)
            self.log("Live Activity atualizada. distancia=\(String(format: "%.2f", distanceKm))km duracao=\(Int(duration))s")
        }
    }

    // MARK: - Encerrar

    func end(
        duration: TimeInterval,
        distanceKm: Double,
        calories: Double,
        pushCount: Int
    ) {
        guard let activity else {
            log("End ignorado: nenhuma Live Activity ativa.")
            return
        }

        let finalState = SkateSessionAttributes.ContentState(
            isRunning: false,
            duration: duration,
            distanceKm: distanceKm,
            calories: calories,
            pushCount: pushCount,
            speedKmh: 0
        )

        let content = ActivityContent(
            state: finalState,
            staleDate: Date().addingTimeInterval(30)
        )

        Task {
            // .default mantém o widget visível por ~30s após encerrar
            await activity.end(content, dismissalPolicy: .default)
            self.log("Live Activity encerrada.")
        }

        self.activity = nil
    }

    // MARK: - Encerrar todas (cleanup)

    func endAll() {
        Task {
            for activity in Activity<SkateSessionAttributes>.activities {
                await activity.end(
                    ActivityContent(
                        state: activity.content.state,
                        staleDate: nil
                    ),
                    dismissalPolicy: .immediate
                )
            }
            self.log("Todas as Live Activities anteriores foram encerradas.")
        }
        self.activity = nil
    }
}
