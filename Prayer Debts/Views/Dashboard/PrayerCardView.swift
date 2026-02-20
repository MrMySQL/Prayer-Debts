import SwiftUI

struct PrayerCardView: View {
    @Environment(\.themeColors) private var colors
    let debt: PrayerDebt
    let onPrayed: () -> Void
    let onUndo: (Int) -> Void

    @State private var showUndo = false
    @State private var ripple = false
    @State private var tapCount = 0
    @State private var undoTimer: Task<Void, Never>?

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

                        if showUndo {
                            Button("Undo (\(tapCount))") {
                                onUndo(tapCount)
                                tapCount = 0
                                undoTimer?.cancel()
                                withAnimation { showUndo = false }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                            .transition(.opacity)
                        } else {
                            Text("offered")
                                .font(.system(size: 13))
                                .foregroundStyle(colors.secondaryText)
                                .transition(.opacity)
                        }
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
        tapCount += 1

        withAnimation { showUndo = true }
        undoTimer?.cancel()
        undoTimer = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            tapCount = 0
            withAnimation { showUndo = false }
        }
    }
}
