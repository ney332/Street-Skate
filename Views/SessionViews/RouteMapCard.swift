//
//  RouteMapCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI
import MapKit

struct RouteMapCard: View {
    let routePoints: [RoutePoint]
    
    var coordinates: [CLLocationCoordinate2D] {
        routePoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    
    var centerCoordinate: CLLocationCoordinate2D {
        guard !coordinates.isEmpty else { return CLLocationCoordinate2D() }
        let avgLat = coordinates.reduce(0) { $0 + $1.latitude } / Double(coordinates.count)
        let avgLon = coordinates.reduce(0) { $0 + $1.longitude } / Double(coordinates.count)
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
    }
    
    var boundingRegion: MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }
        var minLat = coordinates.first!.latitude
        var maxLat = minLat
        var minLon = coordinates.first!.longitude
        var maxLon = minLon
        for c in coordinates {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        let span = MKCoordinateSpan(latitudeDelta: max(0.002, (maxLat - minLat) * 1.3),
                                    longitudeDelta: max(0.002, (maxLon - minLon) * 1.3))
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0,
                                            longitude: (minLon + maxLon) / 2.0)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var body: some View {
        ZStack {
            Map(initialPosition: .region(boundingRegion ?? MKCoordinateRegion(center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
                if coordinates.count > 1 {
                    MapPolyline(coordinates: coordinates)
                        .stroke(Color(hex: "#87FF00"), lineWidth: 3)
                }
                
                if let first = coordinates.first {
                    Annotation("Start", coordinate: first) {
                        Circle()
                            .fill(Color(hex: "#4CAF50"))
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
                if let last = coordinates.last, coordinates.count > 1 {
                    Annotation("End", coordinate: last) {
                        Circle()
                            .fill(Color(hex: "#F44336"))
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .allowsHitTesting(false)
            .frame(height: 200)
            .cornerRadius(16)
            
            // Legend overlay
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    LegendDot(color: Color(hex: "#4CAF50"), label: "Start")
                    LegendDot(color: Color(hex: "#F44336"), label: "End")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(12)
            }
        }
        .frame(height: 200)
        .cornerRadius(16)
    }
}
