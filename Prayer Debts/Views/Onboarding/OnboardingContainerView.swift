import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var step = 0
    @State private var calculatedDebts: [PrayerType: Int] = [:]

    var body: some View {
        Group {
            switch step {
            case 0:
                WelcomeView { withAnimation(.easeInOut(duration: 0.8)) { step = 1 } }
            case 1:
                CalculationMethodView(
                    onAutoCalculate: { withAnimation(.easeInOut(duration: 0.8)) { step = 2 } },
                    onManualEntry: { withAnimation(.easeInOut(duration: 0.8)) { step = 3 } }
                )
            case 2:
                AutoCalculateView { debtPerPrayer in
                    for prayer in PrayerType.allCases {
                        calculatedDebts[prayer] = debtPerPrayer
                    }
                    withAnimation(.easeInOut(duration: 0.8)) { step = 4 }
                }
            case 3:
                ManualEntryView { debts in
                    calculatedDebts = debts
                    withAnimation(.easeInOut(duration: 0.8)) { step = 4 }
                }
            default:
                RevealView(
                    totalPrayers: calculatedDebts.values.reduce(0, +),
                    onReady: completeOnboarding
                )
            }
        }
        .transition(.opacity)
    }

    private func completeOnboarding() {
        for prayer in PrayerType.allCases {
            let debt = PrayerDebt(
                prayerType: prayer,
                totalDebt: calculatedDebts[prayer] ?? 0
            )
            modelContext.insert(debt)
        }
        withAnimation(.easeInOut(duration: 0.8)) {
            hasCompletedOnboarding = true
        }
    }
}
