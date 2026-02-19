import SwiftUI

struct PrayerCardView: View {
    @Environment(\.themeColors) private var colors
    let debt: PrayerDebt
    let onPrayed: () -> Void
    let onUndo: () -> Void

    @State private var showUndo = false
    @State private var ripple = false

    var body: some View {
        Button(action: handleTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(debt.prayerType.arabicName)
                            .font(AppTheme.Typography.arabicPrayerName)
                            .foregroundStyle(colors.secondaryText)

                        Text(debt.prayerType.name)
                            .font(AppTheme.Typography.prayerName)
                            .foregroundStyle(colors.primaryText)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(debt.completedCount.formatted())")
                            .font(AppTheme.Typography.prayerCount)
                            .foregroundStyle(AppTheme.accentStart)
                            .contentTransition(.numericText())

                        Text("offered")
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colors.progressEmpty)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.accentGradient)
                            .frame(width: geo.size.width * debt.progress)
                            .animation(.easeOut(duration: 0.3), value: debt.progress)
                    }
                }
                .frame(height: 4)

                // Undo row
                if showUndo {
                    HStack {
                        Spacer()
                        Button("Undo") {
                            onUndo()
                            withAnimation { showUndo = false }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                    }
                    .transition(.opacity)
                }
            }
            .padding(16)
            .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: ripple)
    }

    private func handleTap() {
        guard debt.remaining > 0 else { return }
        ripple.toggle()
        onPrayed()

        withAnimation { showUndo = true }
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation { showUndo = false }
        }
    }
}
