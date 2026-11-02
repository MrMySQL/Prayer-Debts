import SwiftUI

struct ManualEntryView: View {
    @Environment(\.themeColors) private var colors
    @State private var debts: [PrayerType: String] = [
        .fajr: "", .dhuhr: "", .asr: "", .maghrib: "", .isha: ""
    ]
    let onContinue: (_ debts: [PrayerType: Int]) -> Void
    var onGoBack: (() -> Void)? = nil

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                Text("Enter your debt for\neach prayer")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)

                VStack(spacing: 16) {
                    ForEach(PrayerType.allCases) { prayer in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(prayer.name)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(colors.primaryText)
                                Text(prayer.arabicName)
                                    .font(.system(size: 14))
                                    .foregroundStyle(colors.secondaryText)
                            }

                            Spacer()

                            TextField("0", text: binding(for: prayer))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(colors.primaryText)
                                .frame(width: 100)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .warmCard(cornerRadius: 10)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                WarmButton(title: "Continue") {
                    var result: [PrayerType: Int] = [:]
                    for prayer in PrayerType.allCases {
                        result[prayer] = Int(debts[prayer] ?? "0") ?? 0
                    }
                    onContinue(result)
                }

                Spacer().frame(height: 12)

                if let onGoBack {
                    Button {
                        onGoBack()
                    } label: {
                        Text("Choose a different method")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(colors.secondaryText)
                    }
                }

                Spacer().frame(height: 48)
            }
        }
    }

    private func binding(for prayer: PrayerType) -> Binding<String> {
        Binding(
            get: { debts[prayer] ?? "" },
            set: { debts[prayer] = $0 }
        )
    }
}
