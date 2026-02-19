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
