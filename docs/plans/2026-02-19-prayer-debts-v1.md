# Prayer Debts v1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a complete iOS app for tracking qada (missed) prayer debts with onboarding, dashboard, and settings.

**Architecture:** SwiftUI + SwiftData + CloudKit. Single-target iOS app. No tests target (pure UI app, verify via Xcode build). All files go in `Prayer Debts/Prayer Debts/` — Xcode auto-discovers them via file system synchronized root groups.

**Tech Stack:** Swift 5, SwiftUI, SwiftData, CloudKit, iOS 17+

**Source root:** `/Users/mrmysql/projects/prayer-debts/Prayer Debts/Prayer Debts`

---

### Task 1: Theme System

**Files:**
- Create: `Prayer Debts/Theme/AppTheme.swift`

**Step 1: Create the theme file**

All colors, gradients, and typography constants from the design doc in one place. Both dark and light mode support using `Color` initializers with hex values. The app uses a custom warm color palette — NOT system semantic colors.

```swift
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
```

**Step 2: Build to verify**

Run: `xcodebuild -project "Prayer Debts.xcodeproj" -scheme "Prayer Debts" -destination "generic/platform=iOS" build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "Prayer Debts/Theme"
git commit -m "feat: add app theme system with warm color palette"
```

---

### Task 2: Data Models

**Files:**
- Create: `Prayer Debts/Models/PrayerType.swift`
- Create: `Prayer Debts/Models/PrayerDebt.swift`
- Create: `Prayer Debts/Models/PrayerLog.swift`
- Delete: `Prayer Debts/Item.swift` (template file, no longer needed)

**Step 1: Create PrayerType enum**

```swift
import Foundation

enum PrayerType: Int, Codable, CaseIterable, Identifiable {
    case fajr = 0
    case dhuhr = 1
    case asr = 2
    case maghrib = 3
    case isha = 4

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .fajr: "Fajr"
        case .dhuhr: "Dhuhr"
        case .asr: "Asr"
        case .maghrib: "Maghrib"
        case .isha: "Isha"
        }
    }

    var arabicName: String {
        switch self {
        case .fajr: "الفجر"
        case .dhuhr: "الظهر"
        case .asr: "العصر"
        case .maghrib: "المغرب"
        case .isha: "العشاء"
        }
    }
}
```

**Step 2: Create PrayerDebt SwiftData model**

```swift
import Foundation
import SwiftData

@Model
final class PrayerDebt {
    var prayerTypeRaw: Int
    var totalDebt: Int
    var completedCount: Int

    var prayerType: PrayerType {
        get { PrayerType(rawValue: prayerTypeRaw) ?? .fajr }
        set { prayerTypeRaw = newValue.rawValue }
    }

    var remaining: Int {
        max(totalDebt - completedCount, 0)
    }

    var progress: Double {
        guard totalDebt > 0 else { return 0 }
        return min(Double(completedCount) / Double(totalDebt), 1.0)
    }

    init(prayerType: PrayerType, totalDebt: Int, completedCount: Int = 0) {
        self.prayerTypeRaw = prayerType.rawValue
        self.totalDebt = totalDebt
        self.completedCount = completedCount
    }
}
```

**Step 3: Create PrayerLog SwiftData model**

```swift
import Foundation
import SwiftData

@Model
final class PrayerLog {
    var prayerTypeRaw: Int
    var date: Date

    var prayerType: PrayerType {
        get { PrayerType(rawValue: prayerTypeRaw) ?? .fajr }
        set { prayerTypeRaw = newValue.rawValue }
    }

    init(prayerType: PrayerType, date: Date = .now) {
        self.prayerTypeRaw = prayerType.rawValue
        self.date = date
    }
}
```

**Step 4: Delete Item.swift**

Remove the template `Item.swift` file — it's the Xcode default and unused.

**Step 5: Build to verify**

Run: `xcodebuild build` (same command as before)
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git rm "Prayer Debts/Item.swift"
git add "Prayer Debts/Models"
git commit -m "feat: add prayer data models (PrayerType, PrayerDebt, PrayerLog)"
```

---

### Task 3: App Entry Point & Routing

**Files:**
- Modify: `Prayer Debts/Prayer_DebtsApp.swift`
- Modify: `Prayer Debts/ContentView.swift`

**Step 1: Update Prayer_DebtsApp.swift**

Replace the entire file. Configure SwiftData with CloudKit, use `@AppStorage` for onboarding state, route to onboarding or dashboard.

```swift
import SwiftUI
import SwiftData

@main
struct Prayer_DebtsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PrayerDebt.self,
            PrayerLog.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withAppTheme()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Step 2: Update ContentView.swift**

Replace the entire file. This becomes the router — shows onboarding if not completed, dashboard otherwise.

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            DashboardView()
        } else {
            OnboardingContainerView()
        }
    }
}
```

**Step 3: Create placeholder views so it builds**

Create `Prayer Debts/Views/DashboardView.swift`:
```swift
import SwiftUI

struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
    }
}
```

Create `Prayer Debts/Views/Onboarding/OnboardingContainerView.swift`:
```swift
import SwiftUI

struct OnboardingContainerView: View {
    var body: some View {
        Text("Onboarding")
    }
}
```

**Step 4: Build to verify**

Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: wire up app routing between onboarding and dashboard"
```

---

### Task 4: Onboarding Flow

**Files:**
- Modify: `Prayer Debts/Views/Onboarding/OnboardingContainerView.swift`
- Create: `Prayer Debts/Views/Onboarding/WelcomeView.swift`
- Create: `Prayer Debts/Views/Onboarding/CalculationMethodView.swift`
- Create: `Prayer Debts/Views/Onboarding/AutoCalculateView.swift`
- Create: `Prayer Debts/Views/Onboarding/ManualEntryView.swift`
- Create: `Prayer Debts/Views/Onboarding/RevealView.swift`
- Create: `Prayer Debts/Views/Components/WarmButton.swift`
- Create: `Prayer Debts/Views/Components/WarmBackground.swift`

**Step 1: Create reusable WarmBackground**

The warm dark/light background with radial gradient used on every screen.

```swift
import SwiftUI

struct WarmBackground: View {
    @Environment(\.themeColors) private var colors

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            RadialGradient(
                colors: [
                    colors.cardSurface.opacity(0.12),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.6
            )
            .ignoresSafeArea()
        }
    }
}
```

**Step 2: Create reusable WarmButton**

The amber-gold gradient button used throughout onboarding.

```swift
import SwiftUI

struct WarmButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.accentGradient, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 32)
    }
}
```

**Step 3: Create WelcomeView**

Screen 1 — Bismillah + quote + "Begin" button.

```swift
import SwiftUI

struct WelcomeView: View {
    @Environment(\.themeColors) private var colors
    let onBegin: () -> Void

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("بِسْمِ اللَّهِ")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(colors.primaryText)
                    .padding(.bottom, 40)

                VStack(spacing: 8) {
                    Text("The best time to start")
                        .font(.system(size: 20, weight: .regular))
                    Text("was years ago.")
                        .font(.system(size: 20, weight: .regular))
                }
                .foregroundStyle(colors.primaryText)
                .padding(.bottom, 20)

                VStack(spacing: 8) {
                    Text("The second best time")
                        .font(.system(size: 20, weight: .regular))
                    Text("is now.")
                        .font(.system(size: 20, weight: .medium))
                }
                .foregroundStyle(colors.primaryText)

                Spacer()
                Spacer()

                WarmButton(title: "Begin", action: onBegin)
                    .padding(.bottom, 48)
            }
        }
    }
}
```

**Step 4: Create CalculationMethodView**

Screen 2 — Two option cards.

```swift
import SwiftUI

struct CalculationMethodView: View {
    @Environment(\.themeColors) private var colors
    let onAutoCalculate: () -> Void
    let onManualEntry: () -> Void

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 4) {
                    Text("How would you like")
                    Text("to calculate your")
                    Text("prayer debt?")
                }
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(colors.primaryText)
                .multilineTextAlignment(.center)

                Spacer().frame(height: 40)

                VStack(spacing: 16) {
                    MethodCard(
                        title: "Calculate for me",
                        description: "I'll enter the year I became mukallaf and when I started praying regularly",
                        colors: colors,
                        action: onAutoCalculate
                    )

                    MethodCard(
                        title: "I already know my numbers",
                        description: "I'll enter the count for each prayer myself",
                        colors: colors,
                        action: onManualEntry
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

private struct MethodCard: View {
    let title: String
    let description: String
    let colors: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colors.primaryText)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
```

**Step 5: Create AutoCalculateView**

Screen 3A — Two year pickers + "Calculate" button.

```swift
import SwiftUI

struct AutoCalculateView: View {
    @Environment(\.themeColors) private var colors
    @State private var mukallafYear = Calendar.current.component(.year, from: Date()) - 10
    @State private var startedPrayingYear = Calendar.current.component(.year, from: Date())
    let onCalculate: (_ debtPerPrayer: Int) -> Void

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
                Spacer().frame(height: 60)

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
                .padding(.bottom, 48)
            }
        }
    }
}
```

**Step 6: Create ManualEntryView**

Screen 3B — 5 number inputs.

```swift
import SwiftUI

struct ManualEntryView: View {
    @Environment(\.themeColors) private var colors
    @State private var debts: [PrayerType: String] = [
        .fajr: "", .dhuhr: "", .asr: "", .maghrib: "", .isha: ""
    ]
    let onContinue: (_ debts: [PrayerType: Int]) -> Void

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
                                .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 10))
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
                .padding(.bottom, 48)
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
```

**Step 7: Create RevealView**

Screen 4 — The emotional reveal with staggered animations.

```swift
import SwiftUI

struct RevealView: View {
    @Environment(\.themeColors) private var colors
    let totalPrayers: Int
    let onReady: () -> Void

    @State private var showNumber = false
    @State private var showSubtext = false
    @State private var showAyah = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            WarmBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Your journey is")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(colors.primaryText)

                    Text(totalPrayers.formatted())
                        .font(AppTheme.Typography.journeyNumber)
                        .foregroundStyle(AppTheme.accentStart)
                    + Text(" prayers")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(colors.primaryText)
                }
                .opacity(showNumber ? 1 : 0)

                Text("That's one prayer\nat a time.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .opacity(showSubtext ? 1 : 0)

                VStack(spacing: 8) {
                    Text("إِنَّ مَعَ الْعُسْرِ يُسْرًا")
                        .font(.system(size: 22))
                        .foregroundStyle(colors.primaryText)

                    Text("With hardship comes ease")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(colors.secondaryText)

                    Text("— Quran 94:6")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(colors.secondaryText.opacity(0.7))
                }
                .padding(.top, 48)
                .opacity(showAyah ? 1 : 0)

                Spacer()
                Spacer()

                WarmButton(title: "I'm ready", action: onReady)
                    .padding(.bottom, 48)
                    .opacity(showButton ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { showNumber = true }
            withAnimation(.easeIn(duration: 0.6).delay(0.5)) { showSubtext = true }
            withAnimation(.easeIn(duration: 0.6).delay(1.0)) { showAyah = true }
            withAnimation(.easeIn(duration: 0.6).delay(1.5)) { showButton = true }
        }
    }
}
```

**Step 8: Wire up OnboardingContainerView**

Replace the placeholder with the full flow.

```swift
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
                WelcomeView { withAnimation(.easeInOut(duration: 0.5)) { step = 1 } }
            case 1:
                CalculationMethodView(
                    onAutoCalculate: { withAnimation(.easeInOut(duration: 0.5)) { step = 2 } },
                    onManualEntry: { withAnimation(.easeInOut(duration: 0.5)) { step = 3 } }
                )
            case 2:
                AutoCalculateView { debtPerPrayer in
                    for prayer in PrayerType.allCases {
                        calculatedDebts[prayer] = debtPerPrayer
                    }
                    withAnimation(.easeInOut(duration: 0.5)) { step = 4 }
                }
            case 3:
                ManualEntryView { debts in
                    calculatedDebts = debts
                    withAnimation(.easeInOut(duration: 0.5)) { step = 4 }
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
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}
```

**Step 9: Build to verify**

Expected: BUILD SUCCEEDED

**Step 10: Commit**

```bash
git add "Prayer Debts/Views"
git commit -m "feat: complete onboarding flow (welcome, calculation, reveal)"
```

---

### Task 5: Main Dashboard

**Files:**
- Modify: `Prayer Debts/Views/DashboardView.swift`
- Create: `Prayer Debts/Views/Dashboard/JourneyHeaderView.swift`
- Create: `Prayer Debts/Views/Dashboard/PrayerCardView.swift`

**Step 1: Create JourneyHeaderView**

The top area with total count and progress arc.

```swift
import SwiftUI

struct JourneyHeaderView: View {
    @Environment(\.themeColors) private var colors
    let totalOffered: Int
    let overallProgress: Double

    var body: some View {
        VStack(spacing: 12) {
            Text("\(totalOffered.formatted())")
                .font(AppTheme.Typography.journeyNumber)
                .foregroundStyle(AppTheme.accentStart)
                .contentTransition(.numericText())

            Text("prayers offered")
                .font(AppTheme.Typography.journeyLabel)
                .foregroundStyle(colors.secondaryText)

            // Progress arc
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(colors.progressEmpty, lineWidth: 3)
                    .rotationEffect(.degrees(135))

                Circle()
                    .trim(from: 0, to: 0.75 * overallProgress)
                    .stroke(AppTheme.accentGradient, lineWidth: 3)
                    .rotationEffect(.degrees(135))
            }
            .frame(width: 120, height: 120)
            .overlay {
                // Empty — the arc wraps the number area visually
            }
        }
        .padding(.vertical, 24)
    }
}
```

**Step 2: Create PrayerCardView**

Individual prayer card — tappable, with ripple + undo.

```swift
import SwiftUI

struct PrayerCardView: View {
    @Environment(\.themeColors) private var colors
    let debt: PrayerDebt
    let onPrayed: () -> Void
    let onUndo: () -> Void

    @State private var showUndo = false
    @State private var ripple = false

    var body: some View {
        Button(action: handleTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(debt.prayerType.arabicName)
                            .font(AppTheme.Typography.arabicPrayerName)
                            .foregroundStyle(colors.secondaryText)

                        Text(debt.prayerType.name)
                            .font(AppTheme.Typography.prayerName)
                            .foregroundStyle(colors.primaryText)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("\(debt.completedCount.formatted())")
                                .font(AppTheme.Typography.prayerCount)
                                .foregroundStyle(AppTheme.accentStart)
                                .contentTransition(.numericText())
                        }

                        Text("offered")
                            .font(.system(size: 13))
                            .foregroundStyle(colors.secondaryText)
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colors.progressEmpty)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.accentGradient)
                            .frame(width: geo.size.width * debt.progress)
                            .animation(.easeOut(duration: 0.3), value: debt.progress)
                    }
                }
                .frame(height: 4)

                // Undo row
                if showUndo {
                    HStack {
                        Spacer()
                        Button("Undo") {
                            onUndo()
                            withAnimation { showUndo = false }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                    }
                    .transition(.opacity)
                }
            }
            .padding(16)
            .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: ripple)
    }

    private func handleTap() {
        guard debt.remaining > 0 else { return }
        ripple.toggle()
        onPrayed()

        withAnimation { showUndo = true }
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation { showUndo = false }
        }
    }
}
```

**Step 3: Build DashboardView**

Replace the placeholder with the full dashboard.

```swift
import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PrayerDebt.prayerTypeRaw) private var debts: [PrayerDebt]
    @Query(filter: #Predicate<PrayerLog> { log in
        log.date >= Calendar.current.startOfDay(for: Date())
    }) private var todayLogs: [PrayerLog]

    @State private var showSettings = false

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
                    // Settings gear
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

                    // Journey header
                    JourneyHeaderView(
                        totalOffered: totalOffered,
                        overallProgress: overallProgress
                    )

                    // Prayer cards
                    VStack(spacing: 12) {
                        ForEach(debts) { debt in
                            PrayerCardView(
                                debt: debt,
                                onPrayed: { logPrayer(debt: debt) },
                                onUndo: { undoPrayer(debt: debt) }
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

    private func undoPrayer(debt: PrayerDebt) {
        guard debt.completedCount > 0 else { return }
        withAnimation {
            debt.completedCount -= 1
        }
        // Remove the most recent log for this prayer type
        let prayerRaw = debt.prayerTypeRaw
        let descriptor = FetchDescriptor<PrayerLog>(
            predicate: #Predicate { $0.prayerTypeRaw == prayerRaw },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        if let logs = try? modelContext.fetch(descriptor), let latest = logs.first {
            modelContext.delete(latest)
        }
    }
}
```

**Note on todayLogs query:** The `#Predicate` with `Calendar.current.startOfDay(for: Date())` may not work at compile time because it's not a constant. If build fails, replace with a computed property that fetches manually:

```swift
// Fallback if the query predicate doesn't compile:
@Query private var allLogs: [PrayerLog]

private var todayLogs: [PrayerLog] {
    let startOfDay = Calendar.current.startOfDay(for: Date())
    return allLogs.filter { $0.date >= startOfDay }
}
```

**Step 4: Create SettingsView placeholder**

Create `Prayer Debts/Views/SettingsView.swift`:
```swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Settings")
    }
}
```

**Step 5: Build to verify**

Expected: BUILD SUCCEEDED (may need the fallback todayLogs approach)

**Step 6: Commit**

```bash
git add "Prayer Debts/Views"
git commit -m "feat: build main dashboard with prayer cards and tap interaction"
```

---

### Task 6: Settings Screen

**Files:**
- Modify: `Prayer Debts/Views/SettingsView.swift`

**Step 1: Build the full settings screen**

```swift
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PrayerDebt.prayerTypeRaw) private var debts: [PrayerDebt]

    @State private var editingDebt: PrayerDebt?
    @State private var editValue = ""
    @State private var showRecalculate = false
    @State private var showResetConfirm1 = false
    @State private var showResetConfirm2 = false

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()

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
                        .foregroundStyle(AppTheme.accentStart)

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
                        .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 12))
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
    private func sectionHeader(_ title: String) -> some View {
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
                        .foregroundStyle(AppTheme.accentStart)
                } else {
                    Text("\(debt.totalDebt)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(colors.primaryText)

                    Button("Edit") {
                        editingDebt = debt
                        editValue = "\(debt.totalDebt)"
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.accentStart)
                }
            }
        }
        .padding(16)
        .background(colors.cardSurface, in: RoundedRectangle(cornerRadius: 12))
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
```

**Step 2: Build to verify**

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "Prayer Debts/Views/SettingsView.swift"
git commit -m "feat: complete settings screen with edit, recalculate, and reset"
```

---

### Task 7: Polish & Final Wiring

**Files:**
- Various minor adjustments

**Step 1: Verify full build**

```bash
xcodebuild -project "Prayer Debts.xcodeproj" -scheme "Prayer Debts" -destination "generic/platform=iOS" build 2>&1 | tail -5
```

**Step 2: Final commit**

```bash
git add -A
git commit -m "feat: Prayer Debts v1 complete"
```

---

## File Structure Summary

```
Prayer Debts/
├── Prayer_DebtsApp.swift          (modified)
├── ContentView.swift              (modified — router)
├── Info.plist
├── Prayer_Debts.entitlements
├── Assets.xcassets/
├── Theme/
│   └── AppTheme.swift
├── Models/
│   ├── PrayerType.swift
│   ├── PrayerDebt.swift
│   └── PrayerLog.swift
└── Views/
    ├── DashboardView.swift
    ├── SettingsView.swift
    ├── Components/
    │   ├── WarmBackground.swift
    │   └── WarmButton.swift
    ├── Dashboard/
    │   ├── JourneyHeaderView.swift
    │   └── PrayerCardView.swift
    └── Onboarding/
        ├── OnboardingContainerView.swift
        ├── WelcomeView.swift
        ├── CalculationMethodView.swift
        ├── AutoCalculateView.swift
        ├── ManualEntryView.swift
        └── RevealView.swift
```
