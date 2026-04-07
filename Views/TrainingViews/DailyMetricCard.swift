//
//  DailyMetricCard.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//
import SwiftUI

struct DailyMetricCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let color: Color
    let progress: Double
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.15), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(value)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(unit)
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    Text(label)
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
