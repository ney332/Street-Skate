import SwiftUI
import MapKit

struct SessionRouteMapView: View {
    let routePoints: [RoutePoint]
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition

    init(routePoints: [RoutePoint]) {
        self.routePoints = routePoints
        _cameraPosition = State(initialValue: .region(Self.region(for: routePoints)))
    }

    private var coordinates: [CLLocationCoordinate2D] {
        routePoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $cameraPosition) {
                if coordinates.count > 1 {
                    MapPolyline(coordinates: coordinates)
                        .stroke(Color(hex: "#87FF00"), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                }

                if let first = coordinates.first {
                    Annotation("Start".localized, coordinate: first) {
                        routeMarker(color: Color(hex: "#4CAF50"), symbol: "play.fill")
                    }
                }

                if let last = coordinates.last {
                    Annotation("End".localized, coordinate: last) {
                        routeMarker(color: Color(hex: "#F44336"), symbol: "flag.fill")
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                Button("Close".localized) { dismiss() }
                    .foregroundColor(Color(hex: "#87FF00"))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                HStack(spacing: 14) {
                    LegendDot(color: Color(hex: "#4CAF50"), label: "Start".localized)
                    LegendDot(color: Color(hex: "#F44336"), label: "End".localized)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(14)
            }
            .padding(.top, 56)
            .padding(.leading, 20)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            cameraPosition = .region(Self.region(for: routePoints))
        }
    }

    private func routeMarker(color: Color, symbol: String) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.22))
                .frame(width: 44, height: 44)
            Circle()
                .fill(color)
                .frame(width: 26, height: 26)
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(color: color.opacity(0.35), radius: 8, y: 4)
    }

    static func region(for routePoints: [RoutePoint]) -> MKCoordinateRegion {
        let coordinates = routePoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }

        guard let first = coordinates.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -22.9068, longitude: -43.1729),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(0.003, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.003, (maxLon - minLon) * 1.5)
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}
