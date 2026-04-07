// StreetSkateWidget.swift
// Street Skate – Live Activity (Lock Screen + Dynamic Island)
//
// Target: SOMENTE StreetSkateWidgetExtension
// O @main fica em StreetSkateWidgetExtensionBundle.swift

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Paleta
private extension Color {
    static let skateGreen = Color(red: 0.53, green: 1.00, blue: 0.00) // #87FF00
    static let skateDark  = Color(red: 0.07, green: 0.07, blue: 0.07)
}

// MARK: - Live Activity Widget
@main
struct StreetSkateWidgetBundle: WidgetBundle {
    var body: some Widget {
        StreetSkateActivityWidget()
    }
}

struct StreetSkateActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SkateSessionAttributes.self) { context in
            MinimalLockScreenView(state: context.state)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(state: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(state: context.state)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "figure.skating")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.skateGreen)
                    Circle()
                        .fill(Color.skateGreen)
                        .frame(width: 6, height: 6)
                }
                .padding(.leading, 4)
            } compactTrailing: {
                Text(context.state.formattedDistance + "km")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.skateGreen)
                    .padding(.trailing, 4)
            } minimal: {
                Image(systemName: "figure.skating")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.skateGreen)
            }
            .keylineTint(Color.skateGreen)
        }
    }
}

// MARK: - Minimal Lock Screen View

struct MinimalLockScreenView: View {
    let state: SkateSessionAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.skating")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.skateGreen)

            VStack(alignment: .leading, spacing: 4) {
                Text("Street Skate")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text(state.formattedDuration)
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
            }

            Spacer()

            HStack(spacing: 12) {
                Text("\(state.formattedDistance) km")
                Text("\(Int(state.calories)) kcal")
                Text("\(state.pushCount) remadas")
            }
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.skateDark)
        .activityBackgroundTint(Color.skateDark)
        .activitySystemActionForegroundColor(Color.skateGreen)
    }
}

// MARK: - Dynamic Island: Expanded Regions

struct ExpandedLeadingView: View {
    let state: SkateSessionAttributes.ContentState
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.skateGreen.opacity(0.2))
                    .frame(width: 30, height: 30)
                Image(systemName: "figure.skating")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.skateGreen)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Street Skate")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                HStack(spacing: 3) {
                    Circle()
                        .fill(state.isRunning ? Color.skateGreen : Color.orange)
                        .frame(width: 5, height: 5)
                    Text(state.isRunning ? "Live" : "Paused")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.leading, 4)
    }
}

struct ExpandedTrailingView: View {
    let state: SkateSessionAttributes.ContentState
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(state.formattedDistance)
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundStyle(Color.skateGreen)
            Text("km")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.trailing, 4)
    }
}

struct ExpandedCenterView: View {
    let state: SkateSessionAttributes.ContentState
    var body: some View {
        Text(state.formattedDuration)
            .font(.system(size: 22, weight: .black, design: .monospaced))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct ExpandedBottomView: View {
    let state: SkateSessionAttributes.ContentState
    var body: some View {
        HStack {
            VStack(spacing: 1) {
                Image(systemName: "speedometer").font(.system(size: 10)).foregroundStyle(.white.opacity(0.6))
                Text(state.formattedSpeed).font(.system(size: 13, weight: .black, design: .monospaced)).foregroundStyle(.white)
                Text("km/h").font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
            }.frame(maxWidth: .infinity)

            Rectangle().fill(Color.white.opacity(0.15)).frame(width: 1, height: 28)

            VStack(spacing: 1) {
                Image(systemName: "flame.fill").font(.system(size: 10)).foregroundStyle(Color(red: 1, green: 0.5, blue: 0.1))
                Text("\(Int(state.calories))").font(.system(size: 13, weight: .black, design: .monospaced)).foregroundStyle(.white)
                Text("kcal").font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
            }.frame(maxWidth: .infinity)

            Rectangle().fill(Color.white.opacity(0.15)).frame(width: 1, height: 28)

            VStack(spacing: 1) {
                Image(systemName: "arrow.forward.circle.fill").font(.system(size: 10)).foregroundStyle(Color(red: 0.4, green: 0.7, blue: 1.0))
                Text("\(state.pushCount)").font(.system(size: 13, weight: .black, design: .monospaced)).foregroundStyle(.white)
                Text("remadas").font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
            }.frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
    }
}


//
//
//import ActivityKit
//import WidgetKit
//import SwiftUI
//
//// MARK: - Attributes (cópia idêntica à do app principal)
//struct FlightLiveActivityAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        var gate: String
//        var flightTime: String
//    }
//    var flightNumber: String
//}
//
//// MARK: - Home Screen Widget
//private struct FlightStatusEntry: TimelineEntry {
//    let date: Date
//    let flightNumber: String
//    let gate: String
//    let flightTime: String
//}
//
//private struct FlightStatusProvider: TimelineProvider {
//    func placeholder(in context: Context) -> FlightStatusEntry {
//        FlightStatusEntry(
//            date: .now,
//            flightNumber: "G3 1234",
//            gate: "B7",
//            flightTime: "14:35"
//        )
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (FlightStatusEntry) -> Void) {
//        completion(placeholder(in: context))
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<FlightStatusEntry>) -> Void) {
//        let entry = placeholder(in: context)
//        completion(Timeline(entries: [entry], policy: .never))
//    }
//}
//
//struct FlightStatusWidget: Widget {
//    let kind = "FlightStatusWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: FlightStatusProvider()) { entry in
//            FlightStatusWidgetView(entry: entry)
//        }
//        .configurationDisplayName("Resumo do voo")
//        .description("Mostra o portao e o horario do seu proximo voo.")
//        .supportedFamilies([.systemSmall, .systemMedium])
//    }
//}
//
//private struct FlightStatusWidgetView: View {
//    let entry: FlightStatusEntry
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                colors: [
//                    Color(red: 0.93, green: 0.96, blue: 1.0),
//                    Color.white
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//
//            VStack(alignment: .leading, spacing: 10) {
//                HStack {
//                    Image(systemName: "airplane.departure")
//                        .foregroundStyle(Color(red: 0.216, green: 0.541, blue: 0.867))
//                    Text(entry.flightNumber)
//                        .font(.headline)
//                    Spacer()
//                }
//
//                HStack(spacing: 12) {
//                    statusBlock(title: "PORTAO", value: entry.gate, color: Color(red: 0.324, green: 0.290, blue: 0.718))
//                    statusBlock(title: "HORARIO", value: entry.flightTime, color: Color(red: 0.216, green: 0.541, blue: 0.867))
//                }
//
//                Spacer(minLength: 0)
//            }
//            .padding()
//        }
//        .containerBackground(for: .widget) {
//            Color.clear
//        }
//    }
//
//    private func statusBlock(title: String, value: String, color: Color) -> some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//            Text(value.isEmpty ? "—" : value)
//                .font(.title3.weight(.bold))
//                .foregroundStyle(color)
//                .minimumScaleFactor(0.7)
//                .lineLimit(1)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//// MARK: - Entry Point da Widget Extension
//@main
//struct FlightWidgetBundle: WidgetBundle {
//    var body: some Widget {
//        FlightStatusWidget()
//        FlightLiveActivityWidget()
//    }
//}
//
//// MARK: - Live Activity Configuration
//struct FlightLiveActivityWidget: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: FlightLiveActivityAttributes.self) { context in
//            LockScreenView(context: context)
//        } dynamicIsland: { context in
//            DynamicIsland {
//                DynamicIslandExpandedRegion(.leading) {
//                    VStack(alignment: .leading, spacing: 2) {
//                        Label("Portão", systemImage: "door.right.hand.open")
//                            .font(.caption2)
//                            .foregroundStyle(.secondary)
//                        Text(context.state.gate.isEmpty ? "—" : context.state.gate)
//                            .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(Color(red: 0.324, green: 0.290, blue: 0.718))
//                    }
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    VStack(alignment: .trailing, spacing: 2) {
//                        Label("Horário", systemImage: "airplane")
//                            .font(.caption2)
//                            .foregroundStyle(.secondary)
//                        Text(context.state.flightTime.isEmpty ? "—" : context.state.flightTime)
//                            .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(Color(red: 0.216, green: 0.541, blue: 0.867))
//                    }
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    HStack {
//                        Image(systemName: "airplane.departure")
//                            .foregroundStyle(.secondary)
//                        Text("Voo \(context.attributes.flightNumber)")
//                            .font(.subheadline).fontWeight(.medium)
//                        Spacer()
//                        Text("Boa viagem! ✈️")
//                            .font(.caption).foregroundStyle(.secondary)
//                    }
//                    .padding(.top, 4)
//                }
//            } compactLeading: {
//                Image(systemName: "door.right.hand.open")
//                    .foregroundStyle(Color(red: 0.324, green: 0.290, blue: 0.718))
//            } compactTrailing: {
//                Text(context.state.gate.isEmpty ? "—" : context.state.gate)
//                    .font(.system(size: 13, weight: .bold, design: .rounded))
//                    .foregroundStyle(Color(red: 0.324, green: 0.290, blue: 0.718))
//            } minimal: {
//                Image(systemName: "airplane")
//                    .foregroundStyle(Color(red: 0.216, green: 0.541, blue: 0.867))
//            }
//        }
//    }
//}
//
//// MARK: - Lock Screen View
//struct LockScreenView: View {
//    let context: ActivityViewContext<FlightLiveActivityAttributes>
//
//    var body: some View {
//        HStack(spacing: 0) {
//            gateColumn
//            divider
//            timeColumn
//            divider
//            flightColumn
//        }
//        .padding(.vertical, 14)
//        .padding(.horizontal, 16)
//        .activityBackgroundTint(Color(.systemBackground))
//        .activitySystemActionForegroundColor(.primary)
//    }
//
//    private var gateColumn: some View {
//        VStack(spacing: 4) {
//            Image(systemName: "door.right.hand.open")
//                .font(.system(size: 20))
//                .foregroundStyle(Color(red: 0.324, green: 0.290, blue: 0.718))
//            Text("PORTÃO")
//                .font(.system(size: 9, weight: .semibold))
//                .foregroundStyle(.secondary)
//            Text(context.state.gate.isEmpty ? "—" : context.state.gate)
//                .font(.system(size: 34, weight: .bold, design: .rounded))
//                .foregroundStyle(Color(red: 0.324, green: 0.290, blue: 0.718))
//                .minimumScaleFactor(0.5)
//                .lineLimit(1)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private var timeColumn: some View {
//        VStack(spacing: 4) {
//            Image(systemName: "airplane")
//                .font(.system(size: 20))
//                .foregroundStyle(Color(red: 0.216, green: 0.541, blue: 0.867))
//            Text("HORÁRIO")
//                .font(.system(size: 9, weight: .semibold))
//                .foregroundStyle(.secondary)
//            Text(context.state.flightTime.isEmpty ? "—" : context.state.flightTime)
//                .font(.system(size: 34, weight: .bold, design: .rounded))
//                .foregroundStyle(Color(red: 0.216, green: 0.541, blue: 0.867))
//                .minimumScaleFactor(0.5)
//                .lineLimit(1)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private var flightColumn: some View {
//        VStack(spacing: 4) {
//            Image(systemName: "number")
//                .font(.system(size: 20))
//                .foregroundStyle(.secondary)
//            Text("VOO")
//                .font(.system(size: 9, weight: .semibold))
//                .foregroundStyle(.secondary)
//            Text(context.attributes.flightNumber.isEmpty ? "—" : context.attributes.flightNumber)
//                .font(.system(size: 20, weight: .bold, design: .rounded))
//                .foregroundStyle(.primary)
//                .minimumScaleFactor(0.5)
//                .lineLimit(1)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private var divider: some View {
//        Rectangle()
//            .fill(Color(.systemGray4))
//            .frame(width: 1, height: 50)
//    }
//}
