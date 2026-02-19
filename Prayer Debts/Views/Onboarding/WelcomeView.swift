import SwiftUI

struct WelcomeView: View {
    @Environment(\.themeColors) private var colors
    let onBegin: () -> Void

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("بِسْمِ اللَّهِ")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(colors.primaryText)
                    .padding(.bottom, 40)

                VStack(spacing: 8) {
                    Text("The best time to start")
                        .font(.system(size: 20, weight: .regular))
                    Text("was years ago.")
                        .font(.system(size: 20, weight: .regular))
                }
                .foregroundStyle(colors.primaryText)
                .padding(.bottom, 20)

                VStack(spacing: 8) {
                    Text("The second best time")
                        .font(.system(size: 20, weight: .regular))
                    Text("is now.")
                        .font(.system(size: 20, weight: .medium))
                }
                .foregroundStyle(colors.primaryText)

                Spacer()
                Spacer()

                WarmButton(title: "Begin", action: onBegin)
                    .padding(.bottom, 48)
            }
        }
    }
}
