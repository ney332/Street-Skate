//
//  SpotsService.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import MapKit
import CoreLocation
import Combine

class SpotsService: ObservableObject {
    @Published var nearbySpots: [SkateSpot] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Search Nearby Spots
    func searchNearbySpots(location: CLLocation) {
        searchTask?.cancel()
        isLoading = true
        
        searchTask = Task {
            var results: [SkateSpot] = []
            
            let queries = ["skate park", "skateboard park", "skatepark", "praça skate", "pista skate"]
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 20000,
                longitudinalMeters: 20000
            )
            
            for query in queries {
                if Task.isCancelled { break }
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = query
                request.region = region
                request.resultTypes = [.pointOfInterest, .address]
                
                do {
                    let search = MKLocalSearch(request: request)
                    let response = try await search.start()
                    
                    for item in response.mapItems {
                        let spotLocation = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                        let distance = location.distance(from: spotLocation)
                        
                        // Avoid duplicates
                        let isDuplicate = results.contains { existing in
                            let existingLoc = CLLocation(latitude: existing.coordinate.latitude, longitude: existing.coordinate.longitude)
                            return spotLocation.distance(from: existingLoc) < 50
                        }
                        
                        if !isDuplicate && distance < 20000 {
                            let spot = SkateSpot(
                                name: item.name ?? "Skate Spot",
                                type: classifySpot(name: item.name ?? "", category: item.pointOfInterestCategory),
                                coordinate: item.placemark.coordinate,
                                distanceMeters: distance,
                                rating: Double.random(in: 3.8...5.0).rounded(toPlaces: 1),
                                imageName: "skateboard"
                            )
                            results.append(spot)
                        }
                    }
                } catch {
                    // Silently handle search errors
                }
            }
            
            // Sort by distance, take top 10
            let sorted = results.sorted { $0.distanceMeters < $1.distanceMeters }.prefix(10)
            
            if !Task.isCancelled {
                await MainActor.run {
                    self.nearbySpots = Array(sorted)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func classifySpot(name: String, category: MKPointOfInterestCategory?) -> SpotType {
        let lower = name.lowercased()
        if lower.contains("park") || lower.contains("pista") { return .park }
        if lower.contains("bowl") { return .bowl }
        if lower.contains("plaza") || lower.contains("praça") { return .plaza }
        if lower.contains("street") || lower.contains("rua") { return .street }
        return .park
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
