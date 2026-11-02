import SwiftUI

struct WarmButton: View {
    @Environment(\.themeColors) private var colors
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(colors.accentGradient, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 32)
    }
}
