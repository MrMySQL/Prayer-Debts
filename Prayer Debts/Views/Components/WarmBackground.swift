import SwiftUI

/// Dark: "warm darkness" — a distant lantern glowing from above (`bg2`).
/// Light: cream paper under soft daylight from a high window (`bgLight`,
/// generated with gpt-5.4-image-2 from the light-mode prompt in DESIGN.md).
struct WarmBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(colorScheme == .dark ? "bg2" : "bgLight")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview("Light") {
    WarmBackground().preferredColorScheme(.light)
}

#Preview("Dark") {
    WarmBackground().preferredColorScheme(.dark)
}
