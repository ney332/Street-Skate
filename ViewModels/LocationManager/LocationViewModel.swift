import Foundation
import CoreLocation
import Combine
import MapKit

// MARK: - Location ViewModel
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var hasStartedUpdates = false
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isUsingLocation: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func requestLocation() {
        let status = locationManager.authorizationStatus

        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            return
        }

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            isUsingLocation = false
            return
        }

        guard !hasStartedUpdates else { return }
        locationManager.startUpdatingLocation()
        hasStartedUpdates = true
        isUsingLocation = true
    }
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
        hasStartedUpdates = false
        isUsingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            requestLocation()
        } else {
            locationManager.stopUpdatingLocation()
            hasStartedUpdates = false
            isUsingLocation = false
        }
    }
}
