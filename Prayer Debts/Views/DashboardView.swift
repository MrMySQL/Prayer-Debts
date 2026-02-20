import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PrayerDebt.prayerTypeRaw) private var debts: [PrayerDebt]
    @Query private var allLogs: [PrayerLog]

    @State private var showSettings = false

    private var todayLogs: [PrayerLog] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return allLogs.filter { $0.date >= startOfDay }
    }

    private var totalOffered: Int {
        debts.reduce(0) { $0 + $1.completedCount }
    }

    private var totalDebt: Int {
        debts.reduce(0) { $0 + $1.totalDebt }
    }

    private var overallProgress: Double {
        guard totalDebt > 0 else { return 0 }
        return Double(totalOffered) / Double(totalDebt)
    }

    var body: some View {
        ZStack {
            WarmBackground()

            ScrollView {
                VStack(spacing: 16) {
                    ZStack() {
                        // Journey header
                        JourneyHeaderView(
                            totalOffered: totalOffered,
                            overallProgress: overallProgress
                        )
                        
                        // Settings gear
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    showSettings = true
                                } label: {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 20))
                                        .foregroundStyle(colors.secondaryText)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))

                    // Prayer cards
                    VStack(spacing: 12) {
                        ForEach(debts) { debt in
                            PrayerCardView(
                                debt: debt,
                                onPrayed: { logPrayer(debt: debt) },
                                onUndo: { count in undoPrayers(debt: debt, count: count) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Today counter
                    Text("Today: +\(todayLogs.count)")
                        .font(AppTheme.Typography.todayCounter)
                        .foregroundStyle(colors.secondaryText)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func logPrayer(debt: PrayerDebt) {
        withAnimation {
            debt.completedCount += 1
        }
        let log = PrayerLog(prayerType: debt.prayerType)
        modelContext.insert(log)
    }

    private func undoPrayers(debt: PrayerDebt, count: Int) {
        let actual = min(count, debt.completedCount)
        guard actual > 0 else { return }
        withAnimation {
            debt.completedCount -= actual
        }
        let prayerRaw = debt.prayerTypeRaw
        let matching = allLogs
            .filter { $0.prayerTypeRaw == prayerRaw }
            .sorted { $0.date > $1.date }
        for log in matching.prefix(actual) {
            modelContext.delete(log)
        }
    }
}
