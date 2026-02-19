import SwiftUI

enum AppTheme {
    // MARK: - Dark Mode Colors
    enum Dark {
        static let background = Color(red: 0.078, green: 0.071, blue: 0.063)       // #141210
        static let cardSurface = Color(red: 0.118, green: 0.110, blue: 0.098)      // #1E1C19
        static let primaryText = Color(red: 0.961, green: 0.941, blue: 0.910)      // #F5F0E8
        static let secondaryText = Color(red: 0.541, green: 0.510, blue: 0.475)    // #8A8279
        static let progressEmpty = Color(red: 0.145, green: 0.137, blue: 0.125)    // #252320
        static let dangerMuted = Color(red: 0.784, green: 0.416, blue: 0.416)      // #C86A6A
    }

    // MARK: - Light Mode Colors
    enum Light {
        static let background = Color(red: 0.980, green: 0.969, blue: 0.949)       // #FAF7F2
        static let cardSurface = Color.white
        static let primaryText = Color(red: 0.118, green: 0.110, blue: 0.098)      // #1E1C19
        static let secondaryText = Color(red: 0.541, green: 0.510, blue: 0.475)    // #8A8279
        static let progressEmpty = Color(red: 0.922, green: 0.910, blue: 0.890)    // #EBE8E3
        static let dangerMuted = Color(red: 0.698, green: 0.302, blue: 0.302)      // #B24D4D
    }

    // MARK: - Accent Gradient (same in both modes)
    static let accentStart = Color(red: 0.784, green: 0.584, blue: 0.424)          // #C8956C
    static let accentEnd = Color(red: 0.910, green: 0.769, blue: 0.486)            // #E8C47C
    static let accentGradient = LinearGradient(
        colors: [accentStart, accentEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

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

// MARK: - Environment-Aware Color Helpers
struct ThemeColors {
    let colorScheme: ColorScheme

    var background: Color { colorScheme == .dark ? AppTheme.Dark.background : AppTheme.Light.background }
    var cardSurface: Color { colorScheme == .dark ? AppTheme.Dark.cardSurface : AppTheme.Light.cardSurface }
    var primaryText: Color { colorScheme == .dark ? AppTheme.Dark.primaryText : AppTheme.Light.primaryText }
    var secondaryText: Color { colorScheme == .dark ? AppTheme.Dark.secondaryText : AppTheme.Light.secondaryText }
    var progressEmpty: Color { colorScheme == .dark ? AppTheme.Dark.progressEmpty : AppTheme.Light.progressEmpty }
    var dangerMuted: Color { colorScheme == .dark ? AppTheme.Dark.dangerMuted : AppTheme.Light.dangerMuted }
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

// MARK: - View Modifier
struct ThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.themeColors, ThemeColors(colorScheme: colorScheme))
    }
}

extension View {
    func withAppTheme() -> some View {
        modifier(ThemeModifier())
    }
}
