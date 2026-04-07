import SwiftUI

enum TrainingMetricType: String, Identifiable {
    case calories
    case distance
    case pushes
    case activity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calories: return "Calories".localized
        case .distance: return "Distance".localized
        case .pushes: return "Push".localized
        case .activity: return "Activity Today".localized
        }
    }

    var subtitle: String {
        switch self {
        case .calories: return "metric.detail.calories.subtitle".localized
        case .distance: return "metric.detail.distance.subtitle".localized
        case .pushes: return "metric.detail.pushes.subtitle".localized
        case .activity: return "metric.detail.activity.subtitle".localized
        }
    }

    var unit: String {
        switch self {
        case .calories: return "kcal"
        case .distance: return "km"
        case .pushes: return "rmd"
        case .activity: return "metric.detail.minutes_unit".localized
        }
    }

    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .distance: return "figure.skating"
        case .pushes: return "arrow.forward"
        case .activity: return "chart.bar.xaxis"
        }
    }

    var color: Color {
        switch self {
        case .calories: return Color(hex: "#FF6B35")
        case .distance: return Color(hex: "#2196F3")
        case .pushes: return Color(hex: "#4CAF50")
        case .activity: return Color(hex: "#87FF00")
        }
    }
}

struct MetricBarEntry: Identifiable {
    let date: Date
    let value: Double

    var id: TimeInterval { date.timeIntervalSince1970 }
}

struct MetricDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let metric: TrainingMetricType
    let entries: [MetricBarEntry]
    let totalValue: Double
    let averageValue: Double

    private var peakValue: Double {
        max(entries.map(\.value).max() ?? 0, 1)
    }

    private var totalLabel: String {
        switch metric {
        case .calories, .pushes, .activity:
            return String(Int(totalValue.rounded()))
        case .distance:
            return String(format: "%.2f", totalValue)
        }
    }

    private var averageLabel: String {
        switch metric {
        case .calories, .pushes, .activity:
            return String(Int(averageValue.rounded()))
        case .distance:
            return String(format: "%.2f", averageValue)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(metric.color.opacity(0.16))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: metric.icon)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(metric.color)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(metric.title)
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(metric.subtitle)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.55))
                                }
                            }
                        }

                        HStack(spacing: 12) {
                            MetricSummaryPill(
                                title: "metric.detail.total".localized,
                                value: totalLabel,
                                unit: metric.unit,
                                color: metric.color
                            )
                            MetricSummaryPill(
                                title: "metric.detail.average".localized,
                                value: averageLabel,
                                unit: metric.unit,
                                color: .white.opacity(0.8)
                            )
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("metric.detail.last_7_days".localized)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.75))
                                Spacer()
                                Text(metric.unit)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }

                            HStack(alignment: .bottom, spacing: 10) {
                                ForEach(entries) { entry in
                                    MetricBarColumn(
                                        entry: entry,
                                        metric: metric,
                                        maxValue: peakValue
                                    )
                                }
                            }
                            .frame(height: 220)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                    }
                    .padding(20)
                    .padding(.top, 12)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done".localized) { dismiss() }
                        .foregroundColor(metric.color)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
}

private struct MetricSummaryPill: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.45))

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(unit)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

private struct MetricBarColumn: View {
    let entry: MetricBarEntry
    let metric: TrainingMetricType
    let maxValue: Double

    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter
    }

    private var valueLabel: String {
        switch metric {
        case .calories, .pushes, .activity:
            return String(Int(entry.value.rounded()))
        case .distance:
            return String(format: "%.1f", entry.value)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(valueLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.58))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            GeometryReader { proxy in
                let normalized = max(entry.value / maxValue, 0.06)
                let barHeight = proxy.size.height * normalized

                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [metric.color.opacity(0.55), metric.color],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: barHeight)
                        .shadow(color: metric.color.opacity(0.35), radius: 8, y: 4)
                }
            }

            Text(formatter.string(from: entry.date).uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.42))
        }
        .frame(maxWidth: .infinity)
    }
}
