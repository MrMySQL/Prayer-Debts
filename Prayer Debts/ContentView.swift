import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                DashboardView()
            } else {
                OnboardingContainerView()
            }
        }
        .animation(.easeInOut(duration: 1.2), value: hasCompletedOnboarding)
    }
}
