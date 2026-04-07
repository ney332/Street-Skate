//
//  RecentSessionsSection.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI
struct RecentSessionsSection: View {
    let sessions: [TrainingSession]
    @State private var selectedSession: TrainingSession? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Sessions".localized)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            if sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.skating")
                        .font(.system(size: 36))
                        .foregroundColor(Color.white.opacity(0.2))
                    Text("No sessions yet".localized)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.3))
                    Text("Start your first skate session!".localized)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(sessions) { session in
                    Button(action: { selectedSession = session }) {
                        SessionRowCard(session: session)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailView(session: session)
                .environmentObject(AppState())
        }
    }
}
