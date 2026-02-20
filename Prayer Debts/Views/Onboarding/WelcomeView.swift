import SwiftUI

struct WelcomeView: View {
    @Environment(\.themeColors) private var colors
    let onBegin: () -> Void

    @State private var showBismillah = false
    @State private var showFirstQuote = false
    @State private var showSecondQuote = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("بِسْمِ اللَّهِ")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(colors.primaryText)
                    .padding(.bottom, 40)
                    .opacity(showBismillah ? 1 : 0)

                VStack(spacing: 8) {
                    Text("The best time to start")
                        .font(.system(size: 20, weight: .regular))
                    Text("was years ago.")
                        .font(.system(size: 20, weight: .regular))
                }
                .foregroundStyle(colors.primaryText)
                .padding(.bottom, 20)
                .opacity(showFirstQuote ? 1 : 0)

                VStack(spacing: 8) {
                    Text("The second best time")
                        .font(.system(size: 20, weight: .regular))
                    Text("is now.")
                        .font(.system(size: 20, weight: .medium))
                }
                .foregroundStyle(colors.primaryText)
                .opacity(showSecondQuote ? 1 : 0)

                Spacer()
                Spacer()

                WarmButton(title: "Begin", action: onBegin)
                    .padding(.bottom, 48)
                    .opacity(showButton ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) { showBismillah = true }
            withAnimation(.easeIn(duration: 1.0).delay(1.3)) { showFirstQuote = true }
            withAnimation(.easeIn(duration: 1.0).delay(2.1)) { showSecondQuote = true }
            withAnimation(.easeIn(duration: 1.0).delay(2.9)) { showButton = true }
        }
    }
}
