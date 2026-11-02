import SwiftUI

enum AppTheme {
    // MARK: - Dark Mode Colors ("warm darkness" — lantern light in a quiet mosque)
    enum Dark {
        static let background = Color(hex: 0x141210)
        static let cardSurface = Color(hex: 0x1E1C19)
        static let primaryText = Color(hex: 0xF5F0E8)
        static let secondaryText = Color(hex: 0x8A8279)
        static let progressEmpty = Color(hex: 0x252320)
        static let dangerMuted = Color(hex: 0xC86A6A)
        static let accent = Color(hex: 0xC8956C)
        static let accentGradient = [Color(hex: 0xC8956C), Color(hex: 0xE8C47C)]
        static let cardShadow = Color.clear
        static let cardBorder = Color.clear
    }

    // MARK: - Light Mode Colors ("cream paper under soft daylight")
    enum Light {
        static let background = Color(hex: 0xFAF7F2)
        static let cardSurface = Color(hex: 0xFFFDF9)
        static let primaryText = Color(hex: 0x2A2520)
        static let secondaryText = Color(hex: 0x756C62)
        static let progressEmpty = Color(hex: 0xECE6DC)
        static let dangerMuted = Color(hex: 0xA94545)
        // Deeper amber so accent text clears 4.5:1 on cream, white and the
        // darkest part of the light background image
        static let accent = Color(hex: 0x8A5A2E)
        // Dark enough for the white button label (>= 4.5:1 across the gradient)
        static let accentGradient = [Color(hex: 0x8F5B2C), Color(hex: 0x9E6C33)]
        static let cardShadow = Color(hex: 0x5A4128).opacity(0.08)
        static let cardBorder = Color(hex: 0xE9E1D4)
    }

    // MARK: - Typography
    enum Typography {
        static let journeyNumber = Font.system(size: 48, weight: .light)
        static let journeyLabel = Font.system(size: 14, weight: .regular)
        static let arabicPrayerName = Font.system(size: 16, weight: .regular)
        static let prayerName = Font.system(size: 20, weight: .medium)
        static let prayerCount = Font.system(size: 28, weight: .semibold)
        static let todayCounter = Font.system(size: 13, weight: .regular)
    }
}

// MARK: - Appearance Preference
enum AppearancePreference: String, CaseIterable, Identifiable {
    case system, light, dark

    static let storageKey = "appearancePreference"

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// MARK: - Environment-Aware Color Helpers
struct ThemeColors {
    let colorScheme: ColorScheme

    private var isDark: Bool { colorScheme == .dark }

    var background: Color { isDark ? AppTheme.Dark.background : AppTheme.Light.background }
    var cardSurface: Color { isDark ? AppTheme.Dark.cardSurface : AppTheme.Light.cardSurface }
    var primaryText: Color { isDark ? AppTheme.Dark.primaryText : AppTheme.Light.primaryText }
    var secondaryText: Color { isDark ? AppTheme.Dark.secondaryText : AppTheme.Light.secondaryText }
    var progressEmpty: Color { isDark ? AppTheme.Dark.progressEmpty : AppTheme.Light.progressEmpty }
    var dangerMuted: Color { isDark ? AppTheme.Dark.dangerMuted : AppTheme.Light.dangerMuted }
    var accent: Color { isDark ? AppTheme.Dark.accent : AppTheme.Light.accent }
    var cardShadow: Color { isDark ? AppTheme.Dark.cardShadow : AppTheme.Light.cardShadow }
    var cardBorder: Color { isDark ? AppTheme.Dark.cardBorder : AppTheme.Light.cardBorder }

    var accentGradient: LinearGradient {
        LinearGradient(
            colors: isDark ? AppTheme.Dark.accentGradient : AppTheme.Light.accentGradient,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Environment Key
private struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue = ThemeColors(colorScheme: .dark)
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}

// MARK: - View Modifiers
struct ThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.themeColors, ThemeColors(colorScheme: colorScheme))
    }
}

/// Card surface: flat in dark mode; in light mode a hairline border and a soft
/// warm shadow so white cards don't dissolve into the cream background.
struct WarmCardModifier: ViewModifier {
    @Environment(\.themeColors) private var colors
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(colors.cardSurface, in: shape)
            .overlay(shape.strokeBorder(colors.cardBorder, lineWidth: 0.5))
            .shadow(color: colors.cardShadow, radius: 10, x: 0, y: 3)
    }
}

extension View {
    func withAppTheme() -> some View {
        modifier(ThemeModifier())
    }

    func warmCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(WarmCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Color hex initializer
extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
