import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PrayerDebt.prayerTypeRaw) private var debts: [PrayerDebt]
    @AppStorage(AppearancePreference.storageKey) private var appearance: AppearancePreference = .system

    @State private var editingDebt: PrayerDebt?
    @State private var editValue = ""
    @State private var showRecalculate = false
    @State private var showResetConfirm1 = false
    @State private var showResetConfirm2 = false

    var body: some View {
        NavigationStack {
            ZStack {
//                WarmBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // PRAYER DEBTS section
                        sectionHeader("PRAYER DEBTS")

                        VStack(spacing: 12) {
                            ForEach(debts) { debt in
                                debtCard(debt)
                            }
                        }
                        .padding(.horizontal, 20)

                        Button("Recalculate from dates") {
                            showRecalculate = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(colors.accent)

                        // APPEARANCE section
                        sectionHeader("APPEARANCE")

                        Picker("Appearance", selection: $appearance) {
                            ForEach(AppearancePreference.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)

                        // ICLOUD section
                        sectionHeader("ICLOUD")

                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.icloud")
                                .foregroundStyle(colors.secondaryText)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Synced")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(colors.primaryText)
                                Text("Automatic via iCloud")
                                    .font(.system(size: 13))
                                    .foregroundStyle(colors.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .warmCard(cornerRadius: 12)
                        .padding(.horizontal, 20)

                        // ABOUT section
                        sectionHeader("ABOUT")

                        VStack(spacing: 4) {
                            Text("Version 1.0")
                                .font(.system(size: 14))
                                .foregroundStyle(colors.secondaryText)
                            Text("Made with ikhlas")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(colors.secondaryText)
                        }

                        // RESET
                        Button("Reset all data") {
                            showResetConfirm1 = true
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(colors.dangerMuted)
                        .padding(.top, 32)
                        .padding(.bottom, 48)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(colors.primaryText)
                    }
                }
            }
            .sheet(isPresented: $showRecalculate) {
                RecalculateSheet(debts: debts)
            }
            .alert("Reset all data?", isPresented: $showResetConfirm1) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) { showResetConfirm2 = true }
            } message: {
                Text("This will permanently delete all your prayer data. This cannot be undone.")
            }
            .alert("Are you sure?", isPresented: $showResetConfirm2) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Everything", role: .destructive) { resetAllData() }
            } message: {
                Text("All your progress will be lost.")
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colors.secondaryText)
                .kerning(1)
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func debtCard(_ debt: PrayerDebt) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(debt.prayerType.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(colors.primaryText)
                    Text(debt.prayerType.arabicName)
                        .font(.system(size: 14))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
            }

            HStack {
                Text("Offered")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
                Spacer()
                Text("\(debt.completedCount)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(colors.primaryText)
            }

            HStack {
                Text("Total debt")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
                Spacer()

                if editingDebt === debt {
                    TextField("0", text: $editValue)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryText)
                        .frame(width: 80)
                        .onSubmit { saveEdit(debt) }

                    Button("Save") { saveEdit(debt) }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.accent)
                } else {
                    Text("\(debt.totalDebt)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryText)

                    Button("Edit") {
                        editingDebt = debt
                        editValue = "\(debt.totalDebt)"
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colors.accent)
                }
            }
        }
        .padding(16)
        .warmCard(cornerRadius: 12)
    }

    private func saveEdit(_ debt: PrayerDebt) {
        if let newValue = Int(editValue), newValue >= 0 {
            debt.totalDebt = newValue
        }
        editingDebt = nil
    }

    private func resetAllData() {
        for debt in debts {
            modelContext.delete(debt)
        }
        let descriptor = FetchDescriptor<PrayerLog>()
        if let logs = try? modelContext.fetch(descriptor) {
            for log in logs {
                modelContext.delete(log)
            }
        }
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

// MARK: - Recalculate Sheet
struct RecalculateSheet: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.dismiss) private var dismiss
    let debts: [PrayerDebt]

    @State private var mukallafYear = Calendar.current.component(.year, from: Date()) - 10
    @State private var startedPrayingYear = Calendar.current.component(.year, from: Date())
    @State private var showConfirm = false

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var yearRange: [Int] {
        Array(1970...currentYear).reversed()
    }

    private var newDebtPerPrayer: Int {
        max(startedPrayingYear - mukallafYear, 0) * 365
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()

                VStack(spacing: 24) {
                    Text("Recalculate from dates")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(colors.primaryText)

                    Picker("Mukallaf year", selection: $mukallafYear) {
                        ForEach(yearRange, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)

                    Picker("Started praying year", selection: $startedPrayingYear) {
                        ForEach(yearRange, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)

                    WarmButton(title: "Recalculate") {
                        showConfirm = true
                    }

                    Spacer()
                }
                .padding(.top, 24)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .alert("Update prayer debts?", isPresented: $showConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Update") {
                    for debt in debts {
                        debt.totalDebt = newDebtPerPrayer
                    }
                    dismiss()
                }
            } message: {
                Text("This will update your total debt for all prayers to \(newDebtPerPrayer.formatted()) each. Your completed count won't change.")
            }
        }
    }
}
