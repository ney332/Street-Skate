import SwiftUI

struct SessionShareCard: View {
    let session: TrainingSession

    private let canvasSize = CGSize(width: 1080, height: 1080)

    private var routePoints: [CGPoint] {
        let coordinates = session.routePoints.map { ($0.latitude, $0.longitude) }
        guard let first = coordinates.first else { return [] }

        var minLat = first.0
        var maxLat = first.0
        var minLon = first.1
        var maxLon = first.1

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.0)
            maxLat = max(maxLat, coordinate.0)
            minLon = min(minLon, coordinate.1)
            maxLon = max(maxLon, coordinate.1)
        }

        let latRange = max(maxLat - minLat, 0.0001)
        let lonRange = max(maxLon - minLon, 0.0001)
        let frame = CGRect(x: 120, y: 110, width: canvasSize.width - 240, height: canvasSize.height - 430)

        return coordinates.map { coordinate in
            let x = (coordinate.1 - minLon) / lonRange
            let y = 1 - ((coordinate.0 - minLat) / latRange)
            return CGPoint(
                x: frame.minX + frame.width * x,
                y: frame.minY + frame.height * y
            )
        }
    }

    private var durationFormatted: String {
        let total = Int(session.duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Color.clear

            Canvas { context, _ in
                guard routePoints.count > 1 else { return }

                var path = Path()
                path.move(to: routePoints[0])
                for point in routePoints.dropFirst() {
                    path.addLine(to: point)
                }

                context.stroke(
                    path,
                    with: .color(Color(hex: "#FC4C02")),
                    style: StrokeStyle(lineWidth: 28, lineCap: .round, lineJoin: .round)
                )

                if let start = routePoints.first {
                    context.fill(
                        Path(ellipseIn: CGRect(x: start.x - 16, y: start.y - 16, width: 32, height: 32)),
                        with: .color(.black)
                    )
                }

                if let end = routePoints.last {
                    context.fill(
                        Path(ellipseIn: CGRect(x: end.x - 16, y: end.y - 16, width: 32, height: 32)),
                        with: .color(Color(hex: "#FC4C02"))
                    )
                }
            }

            VStack {
                Spacer()

                HStack(alignment: .lastTextBaseline) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(format: "%.2f", session.distanceKm))
                            .font(.system(size: 120, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                        Text("km")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#FC4C02"))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(durationFormatted)
                            .font(.system(size: 88, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                        Text("Duration".localized)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color.black.opacity(0.55))
                    }
                }
                .padding(.horizontal, 96)
                .padding(.bottom, 84)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}
