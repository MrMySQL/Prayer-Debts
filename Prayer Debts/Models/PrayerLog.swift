import Foundation
import SwiftData

@Model
final class PrayerLog {
    var prayerTypeRaw: Int = 0
    var date: Date = Date.now

    var prayerType: PrayerType {
        get { PrayerType(rawValue: prayerTypeRaw) ?? .fajr }
        set { prayerTypeRaw = newValue.rawValue }
    }

    init(prayerType: PrayerType, date: Date = .now) {
        self.prayerTypeRaw = prayerType.rawValue
        self.date = date
    }
}
