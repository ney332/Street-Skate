//
//  ActivitySummaryCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct ActivitySummaryCard: View {
    @ObservedObject var trainingVM: TrainingViewModel
    var action: (() -> Void)? = nil
    
    let hours = Array(0..<24)
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Activity Today".localized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Last 24h".localized)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                // Activity bars
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(0..<24, id: \.self) { hour in
                        let activity = trainingVM.activityByHour[hour] ?? 0
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                activity > 0
                                ? LinearGradient(colors: [Color("verde"), Color("verde")], startPoint: .bottom, endPoint: .top)
                                : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.06)], startPoint: .bottom, endPoint: .top)
                            )
                            .frame(height: max(4, CGFloat(activity) * 40))
                    }
                }
                .frame(height: 40)
                
                HStack {
                    Text("0h")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.3))
                    Spacer()
                    Text("Now".localized)
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .buttonStyle(.plain)
    }
}
