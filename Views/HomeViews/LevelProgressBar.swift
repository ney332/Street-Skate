//
//  LevelProgressBar.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI


struct LevelProgressBar: View {
    let progress: Double

    var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color("verde"), Color(hex: "#FF6B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * clampedProgress, height: 10)
                    .shadow(color: Color("verde").opacity(0.4), radius: 4)
            }
        }
    }
}
