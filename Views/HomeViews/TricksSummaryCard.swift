//
//  TricksSummaryCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct TricksSummaryCard: View {
    let user: UserProfile?
    let onTap: () -> Void
    
    var unlockedCount: Int { user?.unlockedTricks.count ?? 0 }
    var totalCount: Int { SkateTrick.allTricks.count }
    var progress: Double { totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0 }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trick Library".localized)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.5))
                            .textCase(.uppercase)
                            .tracking(1)
                        Text("Your Arsenal".localized)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.3))
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [Color("verde"), Color("verde")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Label("%d unlocked".localized(unlockedCount), systemImage: "lock.open.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("verde"))
                    Spacer()
                    Text("%d to go".localized(totalCount - unlockedCount))
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                // Sample trick chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach((user?.unlockedTricks ?? []).prefix(6), id: \.self) { trick in
                            Text(trick)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color("verde")))
                        }
                    }
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
}
