//
//  SessionViewModel.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import Foundation
import CoreLocation
import SwiftUI
import ActivityKit
import Combine

@MainActor
class SessionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isRunning = false
    @Published var duration: TimeInterval = 0
    @Published var distanceKm: Double = 0
    @Published var calories: Double = 0
    @Published var pushCount: Int = 0
    @Published var routePoints: [RoutePoint] = []

    /// Velocidade instantânea (km/h) — alimenta o widget
    @Published var currentSpeedKmh: Double = 0

    /// Preenchido por TrainingSessionView antes de chamar startSession()
    var userName: String = "Skater"

    var startTime: Date? = nil
    private var timer: Timer?
    private var liveActivityTickCount: Int = 0   // throttle: atualiza widget a cada 5s
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var pausedTime: TimeInterval = 0
    private var sessionStartDate: Date = Date()

    var formattedDuration: String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 1
        // Permite updates de localização mesmo com tela bloqueada
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }

    func setupLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startSession() {
        guard !isRunning, startTime == nil else { return }
        locationManager.requestAlwaysAuthorization()
        startTime = Date()
        sessionStartDate = Date()
        isRunning = true
        routePoints = []
        distanceKm = 0
        calories = 0
        pushCount = 0
        duration = 0
        currentSpeedKmh = 0
        liveActivityTickCount = 0

        // Garante que o location manager está ativo durante a sessão
        locationManager.startUpdatingLocation()

        // Inicia a Live Activity (Lock Screen + Dynamic Island)
        LiveActivityService.shared.start(userName: userName)

        // Usa RunLoop.main com .common para rodar mesmo em background
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            DispatchQueue.main.async {
                self.duration = Date().timeIntervalSince(start) + self.pausedTime
                if Int(self.duration) % 100 == 0 && Int(self.duration) > 0 {
                    self.pushCount += 1
                }
                // Atualiza widget a cada 5 segundos (evita throttle do sistema)
                self.liveActivityTickCount += 1
                if self.liveActivityTickCount % 5 == 0 {
                    LiveActivityService.shared.update(
                        isRunning: self.isRunning,
                        duration: self.duration,
                        distanceKm: self.distanceKm,
                        calories: self.calories,
                        pushCount: self.pushCount,
                        speedKmh: self.currentSpeedKmh
                    )
                }
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func pauseSession() {
        isRunning = false
        pausedTime = duration
        startTime = nil
        timer?.invalidate()
        timer = nil

        // Atualiza o widget para mostrar "PAUSADO"
        LiveActivityService.shared.update(
            isRunning: false,
            duration: duration,
            distanceKm: distanceKm,
            calories: calories,
            pushCount: pushCount,
            speedKmh: 0
        )
    }

    func resumeSession() {
        startTime = Date()
        isRunning = true
        liveActivityTickCount = 0
        locationManager.startUpdatingLocation()

        // Atualiza o widget para "SESSÃO ATIVA"
        LiveActivityService.shared.update(
            isRunning: true,
            duration: duration,
            distanceKm: distanceKm,
            calories: calories,
            pushCount: pushCount,
            speedKmh: currentSpeedKmh
        )

        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            DispatchQueue.main.async {
                self.duration = Date().timeIntervalSince(start) + self.pausedTime
                self.liveActivityTickCount += 1
                if self.liveActivityTickCount % 5 == 0 {
                    LiveActivityService.shared.update(
                        isRunning: self.isRunning,
                        duration: self.duration,
                        distanceKm: self.distanceKm,
                        calories: self.calories,
                        pushCount: self.pushCount,
                        speedKmh: self.currentSpeedKmh
                    )
                }
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func endSession() async -> TrainingSession {
        timer?.invalidate()
        timer = nil
        isRunning = false

        // Encerra a Live Activity com dados finais
        LiveActivityService.shared.end(
            duration: duration,
            distanceKm: distanceKm,
            calories: calories,
            pushCount: pushCount
        )

        return TrainingSession(
            date: sessionStartDate,
            duration: duration,
            distanceKm: distanceKm,
            calories: calories,
            pushCount: pushCount,
            routePoints: routePoints
        )
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRunning, let location = locations.last else { return }

        // Descarta pontos com acurácia ruim (>50m)
        let accuracy = location.horizontalAccuracy
        if accuracy < 0 || accuracy > 50 { return }

        // Velocidade instantânea em km/h (CLLocation já fornece em m/s)
        if location.speed >= 0 {
            currentSpeedKmh = location.speed * 3.6
        }

        if let last = lastLocation {
            let distanceMeters = location.distance(from: last)
            let minStep: CLLocationDistance = 3.0
            if distanceMeters >= minStep {
                distanceKm += distanceMeters / 1000
                calories = distanceKm * 70 * 4.0 / 1000

                routePoints.append(RoutePoint(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timestamp: Date()
                ))

                lastLocation = location
            }
        } else {
            // Primeiro ponto válido
            routePoints.append(RoutePoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: Date()
            ))
            lastLocation = location
        }
    }
}
