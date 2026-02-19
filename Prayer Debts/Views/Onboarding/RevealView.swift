import SwiftUI

struct RevealView: View {
    @Environment(\.themeColors) private var colors
    let totalPrayers: Int
    let onReady: () -> Void

    @State private var showNumber = false
    @State private var showSubtext = false
    @State private var showAyah = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Your journey is")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(colors.primaryText)

                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(totalPrayers.formatted())
                            .font(AppTheme.Typography.journeyNumber)
                            .foregroundStyle(AppTheme.accentStart)
                        Text(" prayers")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(colors.primaryText)
                    }
                }
                .opacity(showNumber ? 1 : 0)

                Text("That's one prayer\nat a time.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .opacity(showSubtext ? 1 : 0)

                VStack(spacing: 8) {
                    Text("إِنَّ مَعَ الْعُسْرِ يُسْرًا")
                        .font(.system(size: 22))
                        .foregroundStyle(colors.primaryText)

                    Text("With hardship comes ease")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(colors.secondaryText)

                    Text("— Quran 94:6")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(colors.secondaryText.opacity(0.7))
                }
                .padding(.top, 48)
                .opacity(showAyah ? 1 : 0)

                Spacer()
                Spacer()

                WarmButton(title: "I'm ready", action: onReady)
                    .padding(.bottom, 48)
                    .opacity(showButton ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { showNumber = true }
            withAnimation(.easeIn(duration: 0.6).delay(0.5)) { showSubtext = true }
            withAnimation(.easeIn(duration: 0.6).delay(1.0)) { showAyah = true }
            withAnimation(.easeIn(duration: 0.6).delay(1.5)) { showButton = true }
        }
    }
}
