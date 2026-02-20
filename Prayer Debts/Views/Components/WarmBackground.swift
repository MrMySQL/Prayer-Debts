import SwiftUI

struct WarmBackground: View {
    @Environment(\.themeColors) private var colors

    var body: some View {
        Image("bg2")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
