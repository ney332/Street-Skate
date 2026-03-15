//
//  MotionService.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import CoreMotion
import Foundation
import Combine

/// Detects skateboard pushes using CoreMotion pedometer + accelerometer heuristics.
/// Falls back gracefully on devices without sensors or when denied.
class MotionService: ObservableObject {
    static let shared = MotionService()

    private let pedometer = CMPedometer()
    private let motionManager = CMMotionManager()
    private let altimeter = CMAltimeter()

    @Published var pushCount: Int = 0
    @Published var currentSpeedKmh: Double = 0
    @Published var floorAscended: Int = 0
    @Published var isAvailable: Bool = false

    private var sessionStart: Date?
    private var pedometerBaseline: Int = 0
    private var rawPushCount: Int = 0
    private var lastAccelZ: Double = 0
    private var pushCooldown: Bool = false

    private init() {
        isAvailable = CMPedometer.isStepCountingAvailable()
    }

    // MARK: - Start
    func startTracking() {
        sessionStart = Date()
        pushCount = 0
        rawPushCount = 0
        currentSpeedKmh = 0

        startPedometer()
        startAccelerometer()
        startAltimeter()
    }

    // MARK: - Stop
    func stopTracking() {
        pedometer.stopUpdates()
        motionManager.stopAccelerometerUpdates()
        altimeter.stopRelativeAltitudeUpdates()
        sessionStart = nil
    }

    // MARK: - Pedometer (step-based push estimate)
    private func startPedometer() {
        guard CMPedometer.isStepCountingAvailable(), let start = sessionStart else { return }

        pedometer.startUpdates(from: start) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            DispatchQueue.main.async {
                // Skateboard pushes ≈ every 3–4 steps
                let steps = data.numberOfSteps.intValue
                self.pushCount = max(self.pushCount, steps / 3)

                if let pace = data.currentPace {
                    // pace is seconds/meter → convert to km/h
                    let mps = 1.0 / pace.doubleValue
                    self.currentSpeedKmh = mps * 3.6
                }
            }
        }
    }

    // MARK: - Accelerometer (detect push impulse)
    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.05 // 20 Hz

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            let z = data.acceleration.z
            let delta = abs(z - self.lastAccelZ)
            self.lastAccelZ = z

            // A push creates a vertical spike > 0.5 g followed by a cooldown
            if delta > 0.5 && !self.pushCooldown {
                self.rawPushCount += 1
                self.pushCooldown = true
                // Merge with pedometer: take the max
                self.pushCount = max(self.pushCount, self.rawPushCount)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.pushCooldown = false
                }
            }
        }
    }

    // MARK: - Altimeter (elevation gain)
    private func startAltimeter() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            let relAltMeters = data.relativeAltitude.doubleValue
            // Approximate floors: 1 floor ≈ 3m
            let floors = max(0, Int(relAltMeters / 3.0))
            self.floorAscended = floors
        }
    }
}