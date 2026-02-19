import SwiftUI

struct JourneyHeaderView: View {
    @Environment(\.themeColors) private var colors
    let totalOffered: Int
    let overallProgress: Double

    var body: some View {
        VStack(spacing: 12) {
            Text("\(totalOffered.formatted())")
                .font(AppTheme.Typography.journeyNumber)
                .foregroundStyle(AppTheme.accentStart)
                .contentTransition(.numericText())

            Text("prayers offered")
                .font(AppTheme.Typography.journeyLabel)
                .foregroundStyle(colors.secondaryText)

            // Progress arc
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(colors.progressEmpty, lineWidth: 3)
                    .rotationEffect(.degrees(135))

                Circle()
                    .trim(from: 0, to: 0.75 * overallProgress)
                    .stroke(AppTheme.accentGradient, lineWidth: 3)
                    .rotationEffect(.degrees(135))
            }
            .frame(width: 120, height: 120)
        }
        .padding(.vertical, 24)
    }
}
