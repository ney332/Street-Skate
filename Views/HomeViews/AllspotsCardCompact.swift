//
//  AllspotsCardCompact.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI
struct AllspotsCardCompact: View {
    @ObservedObject var spotsService: SpotsService
    var recentCount: Int { spotsService.nearbySpots.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#4CAF50"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.2))
            }
            Text("\(recentCount)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("All Spots\n Nearby".localized)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.45))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#4CAF50").opacity(0.15), lineWidth: 1))
        )
    }
}
