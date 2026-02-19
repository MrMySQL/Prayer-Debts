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
