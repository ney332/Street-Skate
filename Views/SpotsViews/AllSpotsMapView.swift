//
//  AllSpotsMapView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI
import MapKit

struct AllSpotsMapView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var spotsService = SpotsService()
    @StateObject private var locationVM = LocationViewModel()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedSpot: SkateSpot? = nil
    @State private var showSpotDetail = false
    @State private var mapStyleIndex = 0

    let mapStyles: [MapStyle] = [
        .standard(elevation: .realistic),
        .hybrid(elevation: .realistic),
        .imagery(elevation: .realistic)
    ]
    let mapStyleLabels = ["Standard", "Hybrid", "Satellite"]

    var body: some View {
        ZStack {
            // Map
            Map(position: $cameraPosition) {
                UserAnnotation()
                ForEach(spotsService.nearbySpots) { spot in
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        Button(action: {
                            selectedSpot = spot
                            withAnimation { showSpotDetail = true }
                        }) {
                            SpotMapPin(type: spot.type, color: spotTypeColor(spot.type))
                        }
                    }
                }
            }
            .mapStyle(mapStyles[mapStyleIndex])
            .ignoresSafeArea()

            // Controls overlay
            VStack {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Map style toggle
                    HStack(spacing: 0) {
                        ForEach(0..<3) { i in
                            Button(action: { mapStyleIndex = i }) {
                                Text(mapStyleLabels[i])
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(mapStyleIndex == i ? .black : .white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(mapStyleIndex == i ? Color(hex: "#FFD700") : Color.clear)
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                // Spot count badge
                if !spotsService.nearbySpots.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(hex: "#FFD700"))
                        Text("\(spotsService.nearbySpots.count) spots found")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }

                if spotsService.isLoading {
                    HStack(spacing: 8) {
//                        ProgressView().scaleEffect(0.8).tint(Color(hex: "#FFD700"))
                        Text("Searching for spots...")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }

                Spacer()

                // Bottom spot list (horizontal)
                if !spotsService.nearbySpots.isEmpty && selectedSpot == nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(spotsService.nearbySpots) { spot in
                                Button(action: {
                                    selectedSpot = spot
                                    withAnimation {
                                        cameraPosition = .region(MKCoordinateRegion(
                                            center: spot.coordinate,
                                            latitudinalMeters: 400,
                                            longitudinalMeters: 400
                                        ))
                                    }
                                }) {
                                    MapSpotChip(spot: spot)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }

                // Selected spot sheet
                if let spot = selectedSpot {
                    SelectedSpotBar(spot: spot, onDismiss: { selectedSpot = nil }, onDetail: { showSpotDetail = true })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
            .environment(\.colorScheme, .dark)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedSpot?.id)
        .sheet(isPresented: $showSpotDetail) {
            if let spot = selectedSpot {
                SpotDetailView(spot: spot)
            }
        }
        .onAppear {
            locationVM.requestLocation()
        }
        .onChange(of: locationVM.currentLocation) { _, loc in
            if let loc, spotsService.nearbySpots.isEmpty {
                spotsService.searchNearbySpots(location: loc)
            }
        }
    }

    func spotTypeColor(_ type: SpotType) -> Color {
        switch type {
        case .park:   return Color(hex: "#4CAF50")
        case .plaza:  return Color(hex: "#2196F3")
        case .street: return Color(hex: "#FF9800")
        case .bowl:   return Color(hex: "#9C27B0")
        case .diy:    return Color(hex: "#F44336")
        }
    }
}

struct MapSpotChip: View {
    let spot: SkateSpot
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: spot.type.icon)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#FFD700"))
            Text(spot.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            Text(spot.distanceText)
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct SelectedSpotBar: View {
    let spot: SkateSpot
    let onDismiss: () -> Void
    let onDetail: () -> Void

    var typeColor: Color {
        switch spot.type {
        case .park:   return Color(hex: "#4CAF50")
        case .plaza:  return Color(hex: "#2196F3")
        case .street: return Color(hex: "#FF9800")
        case .bowl:   return Color(hex: "#9C27B0")
        case .diy:    return Color(hex: "#F44336")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(typeColor.opacity(0.2)).frame(width: 44, height: 44)
                Image(systemName: spot.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(typeColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(spot.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text(spot.type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(typeColor)
                    Text("·")
                        .foregroundColor(Color.white.opacity(0.3))
                    Text(spot.distanceText)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#FFD700"))
                    Text(String(format: "%.1f", spot.rating))
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }

            Spacer()

            Button(action: onDetail) {
                Text("Open")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#FFD700"))
                    .cornerRadius(10)
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(typeColor.opacity(0.3), lineWidth: 1))
        )
        .padding(.horizontal, 12)
    }
}
