//
//  NearbySection.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI
import CoreLocation
struct NearbySection: View {
    @ObservedObject var spotsService: SpotsService
    @ObservedObject var locationVM: LocationViewModel
    var onMapTap: (() -> Void)? = nil

    let mockSpots: [SkateSpot] = [
        SkateSpot(name: "Local Skate Park", type: .park, coordinate: CLLocationCoordinate2D(latitude: -22.9, longitude: -43.17), distanceMeters: 350, rating: 4.7, imageName: "skateboard"),
        SkateSpot(name: "Downtown Plaza", type: .plaza, coordinate: CLLocationCoordinate2D(latitude: -22.93, longitude: -43.17), distanceMeters: 870, rating: 4.5, imageName: "skateboard"),
        SkateSpot(name: "City Bowl", type: .bowl, coordinate: CLLocationCoordinate2D(latitude: -23.0, longitude: -43.37), distanceMeters: 2100, rating: 4.8, imageName: "skateboard"),
    ]

    var displaySpots: [SkateSpot] {
        spotsService.nearbySpots.isEmpty ? mockSpots : spotsService.nearbySpots
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Nearby Spots")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()

                if spotsService.isLoading {
                    Text("Loading spots...")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                } else {
//                    Button(action: { onMapTap?() }) {
//                        HStack(spacing: 4) {
//                            Image(systemName: "map.fill")
//                                .font(.system(size: 11))
//                                .foregroundColor(Color(hex: "#FFD700"))
//                            Text("Map View")
//                                .font(.system(size: 13, weight: .semibold))
//                                .foregroundColor(Color(hex: "#FFD700"))
//                        }
//                    }
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(displaySpots) { spot in
                        NavigationLink(destination: SpotDetailView(spot: spot)) {
                            SpotCard(spot: spot)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
