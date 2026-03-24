//
//  SpotDetailView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI
import MapKit

struct SpotDetailView: View {
    let spot: SkateSpot
    @Environment(\.dismiss) var dismiss
    @State private var cameraPosition: MapCameraPosition
    @State private var showDirections = false

    init(spot: SkateSpot) {
        self.spot = spot
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: spot.coordinate,
                latitudinalMeters: 400,
                longitudinalMeters: 400
            )
        ))
    }

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
        NavigationView {
            ZStack(alignment: .bottom) {
                // Full map
                Map(position: $cameraPosition) {
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        SpotMapPin(type: spot.type, color: typeColor)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea()

                // Bottom info sheet
                VStack(spacing: 0) {
                    // Handle
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 16)

                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(spot.name)
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundColor(.white)

                                HStack(spacing: 10) {
                                    Label(spot.type.rawValue, systemImage: spot.type.icon)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(typeColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(typeColor.opacity(0.15))
                                        .cornerRadius(8)

                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(hex: "#87FF00"))
                                        Text(String(format: "%.1f", spot.rating))
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.7))
                                    }
                                }
                            }

                            Spacer()

                            VStack(spacing: 2) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#87FF00"))
                                Text(spot.distanceText)
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundColor(.white)
                                Text("away")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                        }

                        // Quick stats row
                        HStack(spacing: 12) {
                            SpotStatPill(icon: "person.2.fill", text: "Popular")
                            SpotStatPill(icon: "sun.max.fill", text: "Outdoor")
                            SpotStatPill(icon: "skateboard", text: spot.type.rawValue)
                        }

                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: openInMaps) {
                                HStack(spacing: 8) {
                                    Image(systemName: "map.fill")
                                    Text("Get Directions")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#87FF00"), Color(hex: "#FF8C00")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                            }

                            Button(action: { shareSpot() }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                )
                .environment(\.colorScheme, .dark)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .overlay(alignment: .topLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(.top, 56)
                .padding(.leading, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    func openInMaps() {
        let placemark = MKPlacemark(coordinate: spot.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = spot.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    func shareSpot() {
        let text = "Check out \(spot.name) — a great skate spot \(spot.distanceText) away! 🛹"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }
}

struct SpotMapPin: View {
    let type: SpotType
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
            Image(systemName: type.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(color: color.opacity(0.4), radius: 8, y: 3)
    }
}

struct SpotStatPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.5))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.07))
        .cornerRadius(8)
    }
}
