import SwiftUI

struct CalculationMethodView: View {
    @Environment(\.themeColors) private var colors
    let onAutoCalculate: () -> Void
    let onManualEntry: () -> Void

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("How would you like\nto calculate your\nprayer debt?")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(colors.primaryText)
                .multilineTextAlignment(.center)

                Spacer().frame(height: 40)

                VStack(spacing: 16) {
                    MethodCard(
                        title: "Calculate for me",
                        description: "I'll enter the year I became mukallaf and when I started praying regularly",
                        colors: colors,
                        action: onAutoCalculate
                    )

                    MethodCard(
                        title: "I already know my numbers",
                        description: "I'll enter the count for each prayer myself",
                        colors: colors,
                        action: onManualEntry
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

private struct MethodCard: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let colors: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colors.primaryText)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
