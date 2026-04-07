//
//  SessionRowCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct SessionRowCard: View {
    let session: TrainingSession
    
    var durationText: String {
        let minutes = Int(session.duration) / 60
        let seconds = Int(session.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("verde").opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "figure.skating")
                    .font(.system(size: 20))
                    .foregroundColor(Color("verde"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("\(durationText) • \(String(format: "%.2f", session.distanceKm))km")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(session.calories))")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(Color(hex: "#FF6B35"))
                Text("kcal")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.3))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
