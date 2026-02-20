import SwiftUI

struct JourneyHeaderView: View {
    @Environment(\.themeColors) private var colors
    let totalOffered: Int
    let overallProgress: Double

    // Arc geometry: 270-degree arc with gap at the bottom
    private let trimStart: CGFloat = 0
    private let trimEnd: CGFloat = 0.75
    private let arcRotation: Angle = .degrees(135)
    private let arcSize: CGFloat = 180

    private var trimRange: CGFloat { trimEnd - trimStart }

    private var progressTrimEnd: CGFloat {
        trimStart + trimRange * min(max(overallProgress, 0), 1)
    }

    private var timeGradient: LinearGradient {
        let hour = Calendar.current.component(.hour, from: Date())
        let (start, end): (Color, Color) = switch hour {
        case 4...6:
            (Color(hex: 0x5B7FA6), Color(hex: 0xE8C47C))
        case 7...14:
            (Color(hex: 0xC8956C), Color(hex: 0xE8C47C))
        case 15...17:
            (Color(hex: 0xB87D4A), Color(hex: 0xD4A66A))
        case 18...19:
            (Color(hex: 0xC87A4A), Color(hex: 0x9B7AAD))
        default:
            (Color(hex: 0x4A7B7D), Color(hex: 0xE8C47C))
        }
        return LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing)
    }

    var body: some View {
        VStack(spacing: 0) {
            // "YOUR JOURNEY" label
            Text("YOUR JOURNEY")
                .font(.system(size: 13, weight: .regular))
                .tracking(2)
                .foregroundStyle(colors.secondaryText)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))

            // Arc + center text
            ZStack {
                // Glow behind the progress arc
                Circle()
                    .trim(from: trimStart, to: progressTrimEnd)
                    .stroke(timeGradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .blur(radius: 8)
                    .rotationEffect(arcRotation)
                    .animation(.easeOut(duration: 0.7), value: overallProgress)

                // Background track
                Circle()
                    .trim(from: trimStart, to: trimEnd)
                    .stroke(colors.progressEmpty, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(arcRotation)

                // Progress fill
                Circle()
                    .trim(from: trimStart, to: progressTrimEnd)
                    .stroke(timeGradient, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(arcRotation)
                    .animation(.easeOut(duration: 0.7), value: overallProgress)

                // Center text
                VStack(spacing: 2) {
                    Text("\(totalOffered.formatted())")
                        .font(.system(size: 60, weight: .light))
                        .foregroundStyle(timeGradient)
                        .contentTransition(.numericText())

                    Text("prayers offered")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(EdgeInsets(top: -16, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(width: arcSize, height: arcSize)
        }
        .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0))
        .animation(.easeInOut, value: Calendar.current.component(.hour, from: Date()))
    }
}

// MARK: - Color hex initializer
private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
