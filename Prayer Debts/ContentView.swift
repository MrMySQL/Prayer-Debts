import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(AppearancePreference.storageKey) private var appearance: AppearancePreference = .system

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                DashboardView()
            } else {
                OnboardingContainerView()
            }
        }
        .animation(.easeInOut(duration: 1.2), value: hasCompletedOnboarding)
        .onAppear { applyAppearance(appearance) }
        .onChange(of: appearance) { _, newValue in applyAppearance(newValue) }
    }

    /// Overrides the style on the window itself (rather than `.preferredColorScheme`)
    /// so switching back to "System" also updates already-presented sheets.
    private func applyAppearance(_ preference: AppearancePreference) {
        let style: UIUserInterfaceStyle = switch preference {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
