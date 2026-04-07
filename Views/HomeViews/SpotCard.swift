//
//  File.swift
//  SkateAppp
//
//  Created by Lorran on 24/03/26.
//
import SwiftUI

struct SpotCard: View {
    let spot: SkateSpot
    
    var typeColor: Color {
        switch spot.type {
        case .park: return Color(hex: "#4CAF50")
        case .plaza: return Color(hex: "#2196F3")
        case .street: return Color(hex: "#FF9800")
        case .bowl: return Color(hex: "#9C27B0")
        case .diy: return Color(hex: "#F44336")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Map preview placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 90)
                
                Image(systemName: spot.type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(typeColor.opacity(0.7))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(spot.type.localizedName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(typeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(typeColor.opacity(0.15))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Image(systemName: "location")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.4))
                    Text(spot.distanceText)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color("verde"))
                    Text(String(format: "%.1f", spot.rating))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
