import SwiftUI

struct AutoCalculateView: View {
    @Environment(\.themeColors) private var colors
    @State private var mukallafYear = Calendar.current.component(.year, from: Date()) - 10
    @State private var startedPrayingYear = Calendar.current.component(.year, from: Date())
    let onCalculate: (_ debtPerPrayer: Int) -> Void
    var onGoBack: (() -> Void)? = nil

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var yearRange: [Int] {
        Array(1970...currentYear).reversed()
    }

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("When did you become\nmukallaf?")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)

                Text("(approximately)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(colors.secondaryText)
                    .padding(.top, 4)

                Picker("Mukallaf year", selection: $mukallafYear) {
                    ForEach(yearRange, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                .padding(.horizontal, 60)

                Spacer().frame(height: 32)

                Text("When did you start\npraying regularly?")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)

                Text("If you're not fully regular yet,\nchoose this year")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Picker("Started praying year", selection: $startedPrayingYear) {
                    ForEach(yearRange, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                .padding(.horizontal, 60)

                Spacer()

                WarmButton(title: "Calculate") {
                    let years = max(startedPrayingYear - mukallafYear, 0)
                    let debtPerPrayer = years * 365
                    onCalculate(debtPerPrayer)
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
}
