import Foundation
import CoreLocation
import Combine
import MapKit

// MARK: - Location ViewModel
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - Session ViewModel
class SessionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isRunning = false
    @Published var duration: TimeInterval = 0
    @Published var distanceKm: Double = 0
    @Published var calories: Double = 0
    @Published var pushCount: Int = 0
    @Published var routePoints: [RoutePoint] = []
    
    var startTime: Date? = nil
    private var timer: Timer?
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
        locationManager.distanceFilter = 5
    }
    
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startSession() {
        startTime = Date()
        sessionStartDate = Date()
        isRunning = true
        routePoints = []
        distanceKm = 0
        calories = 0
        pushCount = 0
        duration = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.duration = Date().timeIntervalSince(start) + self.pausedTime
            // Simulate push count (roughly 1 push per 3 seconds while active)
            if Int(self.duration) % 3 == 0 && Int(self.duration) > 0 {
                self.pushCount += 1
            }
        }
    }
    
    func pauseSession() {
        isRunning = false
        pausedTime = duration
        startTime = nil
        timer?.invalidate()
        timer = nil
    }
    
    func resumeSession() {
        startTime = Date()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.duration = Date().timeIntervalSince(start) + self.pausedTime
        }
    }
    
    func endSession() -> TrainingSession {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
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
        
        if let last = lastLocation {
            let distanceMeters = location.distance(from: last)
            if distanceMeters > 2 {
                distanceKm += distanceMeters / 1000
                // MET value for skateboarding ~4.0 kcal/(kg*hour), avg 70kg person
                calories = distanceKm * 70 * 4.0 / 1000
            }
        }
        
        lastLocation = location
        routePoints.append(RoutePoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date()
        ))
    }
}

// MARK: - Training ViewModel
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
}
