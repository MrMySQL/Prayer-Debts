import SwiftUI

struct JourneyHeaderView: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme
    let totalOffered: Int
    let overallProgress: Double

    // Arc geometry: 270-degree arc with gap at the bottom
    private let trimStart: CGFloat = 0
    private let trimEnd: CGFloat = 0.75
    private let arcRotation: Angle = .degrees(135)
    private let arcSize: CGFloat = 180

    private var trimRange: CGFloat { trimEnd - trimStart }

    private var isDark: Bool { colorScheme == .dark }

    private var progressTrimEnd: CGFloat {
        trimStart + trimRange * min(max(overallProgress, 0), 1)
    }

    /// Sky colors through the day. Light mode uses deeper tones of the same hues
    /// so the large number keeps its contrast against the cream background.
    private var timeGradient: LinearGradient {
        let hour = Calendar.current.component(.hour, from: Date())
        let (start, end): (UInt32, UInt32) = switch hour {
        case 4...6:   isDark ? (0x5B7FA6, 0xE8C47C) : (0x4A6C93, 0xB8862F) // Fajr
        case 7...14:  isDark ? (0xC8956C, 0xE8C47C) : (0xA8703F, 0xC0913A) // Day
        case 15...17: isDark ? (0xB87D4A, 0xD4A66A) : (0x9A6436, 0xB5843F) // Asr
        case 18...19: isDark ? (0xC87A4A, 0x9B7AAD) : (0xA85F33, 0x7D5E91) // Maghrib
        default:      isDark ? (0x4A7B7D, 0xE8C47C) : (0x3D6668, 0xB8862F) // Night
        }
        return LinearGradient(
            colors: [Color(hex: start), Color(hex: end)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // "YOUR JOURNEY" label
            Text("YOUR JOURNEY")
                .font(.system(size: 13, weight: .regular))
                .tracking(2)
                .foregroundStyle(isDark ? Color.white : colors.secondaryText)
                // Dark glow keeps the label legible over the lantern light; not needed on cream
                .shadow(color: isDark ? .black : .clear, radius: 2, x: 0, y: 0)
                .shadow(color: isDark ? .black : .clear, radius: 4, x: 0, y: 0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))

            // Arc + center text
            ZStack {
                // Glow behind the progress arc
                Circle()
                    .trim(from: trimStart, to: progressTrimEnd)
                    .stroke(timeGradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .blur(radius: 8)
                    .opacity(isDark ? 1 : 0.45)
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
