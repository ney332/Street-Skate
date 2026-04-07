//
//  DailyMetricsSection.swift
//  SkateAppp
//
//  Created by Lorran on 25/03/26.
//

import SwiftUI

struct DailyMetricsSection: View {
    @ObservedObject var trainingVM: TrainingViewModel
    @State private var selectedMetric: TrainingMetricType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today".localized)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                DailyMetricCard(
                    value: String(format: "%.0f", trainingVM.todayCalories),
                    unit: "kcal",
                    label: "Calories".localized,
                    icon: "flame.fill",
                    color: Color(hex: "#FF6B35"),
                    progress: min(trainingVM.todayCalories / 500, 1.0),
                    action: { selectedMetric = .calories }
                )
                DailyMetricCard(
                    value: String(format: "%.2f", trainingVM.todayDistanceKm),
                    unit: "km",
                    label: "Distance".localized,
                    icon: "figure.skating",
                    color: Color(hex: "#2196F3"),
                    progress: min(trainingVM.todayDistanceKm / 5, 1.0),
                    action: { selectedMetric = .distance }
                )
                DailyMetricCard(
                    value: "\(trainingVM.todayPushCount)",
                    unit: "rmd",
                    label: "Push".localized,
                    icon: "arrow.forward",
                    color: Color(hex: "#4CAF50"),
                    progress: min(Double(trainingVM.todayPushCount) / 200, 1.0),
                    action: { selectedMetric = .pushes }
                )
            }
            
            // Activity Ring Inspired Card
            ActivitySummaryCard(trainingVM: trainingVM, action: { selectedMetric = .activity })
        }
        .sheet(item: $selectedMetric) { metric in
            MetricDetailSheet(
                metric: metric,
                entries: trainingVM.metricEntries(for: metric),
                totalValue: trainingVM.totalValue(for: metric),
                averageValue: trainingVM.averageValue(for: metric)
            )
        }
    }
}
