import SwiftUI

struct WarmBackground: View {
    @Environment(\.themeColors) private var colors

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            RadialGradient(
                colors: [
                    colors.cardSurface.opacity(0.12),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.6
            )
            .ignoresSafeArea()
        }
    }
}
