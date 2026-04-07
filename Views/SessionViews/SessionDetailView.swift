//
//  SessionDetailView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//

import SwiftUI
import MapKit
import UIKit

struct SessionDetailView: View {
    let session: TrainingSession
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil
    @State private var streakCount: Int = 0
    @State private var showFullRoute = false

    var durationFormatted: String {
        let total = Int(session.duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }

    var avgSpeedKph: Double {
        guard session.duration > 0 else { return 0 }
        return session.distanceKm / (session.duration / 3600)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text(session.date.formatted(date: .complete, time: .omitted))
                                .font(.system(size: 15))
                                .foregroundColor(Color.white.opacity(0.4))
                            Text(session.date.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.25))
                        }
                        .padding(.top, 8)

                        if !session.routePoints.isEmpty {
                            Button(action: { showFullRoute = true }) {
                                RouteMapCard(routePoints: session.routePoints)
                                    .padding(.horizontal, 20)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailMetricCard(value: durationFormatted, label: "Duration", icon: "timer", color: Color(hex: "#2196F3"))
                            DetailMetricCard(value: String(format: "%.2f km", session.distanceKm), label: "Distance", icon: "figure.skating", color: Color(hex: "#4CAF50"))
                            DetailMetricCard(value: "\(Int(session.calories)) kcal", label: "Calories", icon: "flame.fill", color: Color(hex: "#FF6B35"))
                            DetailMetricCard(value: "\(session.pushCount)", label: "Push", icon: "arrow.forward.circle", color: Color(hex: "#9C27B0"))
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 12) {
                            SmallDetailMetric(value: String(format: "%.1f km/h", avgSpeedKph), label: "Avg Speed")
                            SmallDetailMetric(value: String(format: "%.0f kcal/km", session.distanceKm > 0 ? session.calories / session.distanceKm : 0), label: "Intensity")
                            SmallDetailMetric(value: String(format: "%.1f", session.distanceKm > 0 ? Double(session.pushCount) / session.distanceKm : 0), label: "Pushes/km")
                        }
                        .padding(.horizontal, 20)

                        if !session.tricksAttempted.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tricks Practiced")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(session.tricksAttempted, id: \.self) { trick in
                                            Text(trick)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(Color(hex: "#87FF00"))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(Color(hex: "#87FF00").opacity(0.12))
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color(hex: "#87FF00").opacity(0.25), lineWidth: 1)
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        shareSessionImage()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "#87FF00"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "#87FF00"))
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showFullRoute) {
            SessionRouteMapView(routePoints: session.routePoints)
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityShareSheet(activityItems: [shareImage])
            }
        }
    }

    private func shareSessionImage() {
        let renderer = ImageRenderer(content: SessionShareCard(session: session))
        renderer.scale = 1
        renderer.isOpaque = false

        if let image = renderer.uiImage {
            shareImage = image
            showShareSheet = true
        }
    }
}
