//
//  MetricsCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct MetricsCard: View {
    let user: UserProfile?
    var onProgressTap: (() -> Void)? = nil

    private var xpText: String {
        let currentXP = user?.xp ?? 0
        let nextThreshold = ((currentXP / 1000) + 1) * 1000
        return "xp.progress".localized(currentXP, nextThreshold)
    }

    private var levelProgress: Double {
        user?.levelProgress ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("All Time Stats")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text(user?.level.localizedName ?? "")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("verde"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("verde").opacity(0.15))
                    .cornerRadius(8)
            }

            HStack(spacing: 12) {
                StatBox(value: "\(user?.totalSessions ?? 0)", label: "Sessions", icon: "calendar")
                StatBox(value: "spot.distance.kilometers".localized(user?.totalDistanceKm ?? 0), label: "Distance", icon: "arrow.triangle.swap")
                StatBox(value: "\(Int(user?.totalCalories ?? 0))", label: "Calories", icon: "flame.fill")
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Level Progress")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.5))
                    Spacer()
                    Text(xpText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("verde"))
                }

                LevelProgressBar(progress: levelProgress)
                    .frame(height: 10)
            }

            Button(action: { onProgressTap?() }) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 14))
                    Text("View Detailed Progress")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color("verde"))
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
