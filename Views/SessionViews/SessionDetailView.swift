//
//  SessionDetailView.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//


import SwiftUI
import MapKit

struct SessionDetailView: View {
    let session: TrainingSession
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil
    @State private var streakCount: Int = 0
    
    var durationFormatted: String {
        let total = Int(session.duration)
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }
    
    var avgSpeedKph: Double {
        guard session.duration > 0 else { return 0 }
        return (session.distanceKm / (session.duration / 3600))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Date header
                        VStack(spacing: 6) {
                            Text(session.date.formatted(date: .complete, time: .omitted))
                                .font(.system(size: 15))
                                .foregroundColor(Color.white.opacity(0.4))
                            Text(session.date.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.25))
                        }
                        .padding(.top, 8)
                        
                        // Map preview (if route available)
                        if !session.routePoints.isEmpty {
                            RouteMapCard(routePoints: session.routePoints)
                                .padding(.horizontal, 20)
                        }
                        
                        // Primary metrics
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailMetricCard(value: durationFormatted, label: "Duration", icon: "timer", color: Color(hex: "#2196F3"))
                            DetailMetricCard(value: String(format: "%.2f km", session.distanceKm), label: "Distance", icon: "figure.skating", color: Color(hex: "#4CAF50"))
                            DetailMetricCard(value: "\(Int(session.calories)) kcal", label: "Calories", icon: "flame.fill", color: Color(hex: "#FF6B35"))
                            DetailMetricCard(value: "\(session.pushCount)", label: "Remadas", icon: "arrow.forward.circle", color: Color(hex: "#9C27B0"))
                        }
                        .padding(.horizontal, 20)
                        
                        // Secondary metrics
                        HStack(spacing: 12) {
                            SmallDetailMetric(value: String(format: "%.1f km/h", avgSpeedKph), label: "Avg Speed")
                            SmallDetailMetric(value: String(format: "%.0f kcal/km", session.distanceKm > 0 ? session.calories / session.distanceKm : 0), label: "Intensity")
                            SmallDetailMetric(value: String(format: "%.1f", session.distanceKm > 0 ? Double(session.pushCount) / session.distanceKm : 0), label: "Pushes/km")
                        }
                        .padding(.horizontal, 20)
                        
                        // Tricks practiced
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
                                                .foregroundColor(Color(hex: "#FFD700"))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(Color(hex: "#FFD700").opacity(0.12))
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color(hex: "#FFD700").opacity(0.25), lineWidth: 1)
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
//                        let img = renderSessionShareCard(
//                            session: session,
//                            userName: appState.currentUser?.name ?? "Skater",
//                            streak: streakCount
//                        )
//                        shareImage = img
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "#FFD700"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "#FFD700"))
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
//        .sheet(isPresented: $showShareSheet) {
//            if let img = shareImage {
//                ShareSheet(items: [img, "Just finished a skate session with SkateFlow! 🛹"])
//            }
        }
//        .onAppear {
//            let service = StreakService()
//            if let data = UserDefaults.standard.data(forKey: "trainingSessions"),
//               let sessions = try? JSONDecoder().decode([TrainingSession].self, from: data) {
//                service.updateStreak(with: sessions)
//                streakCount = service.currentStreak
//            }
//        }
    }
//}

// MARK: - Route Map Card
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
    
    var body: some View {
        ZStack {
            Map {
                if coordinates.count > 1 {
                    MapPolyline(coordinates: coordinates)
                        .stroke(Color(hex: "#FFD700"), lineWidth: 3)
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
            .frame(height: 200)
            .cornerRadius(16)
            .disabled(true)
            
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

struct LegendDot: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
        }
    }
}

// MARK: - Metric Cards
struct DetailMetricCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SmallDetailMetric: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
