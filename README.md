# Prayer Debts

A minimal, emotionally intelligent iOS app for Muslims to track and repay missed (qada) prayers.

## About

Many Muslims carry the weight of missed prayers — sometimes hundreds, sometimes thousands. Prayer Debts turns that overwhelming number into a quiet, manageable journey. One prayer at a time.

## Features

- **5 prayer types** tracked in sacred order: Fajr, Dhuhr, Asr, Maghrib, Isha
- **One-tap logging** — tap a prayer card to record a completed qada prayer
- **Batch undo** — quickly undo multiple taps at once
- **Progress-first framing** — the app celebrates what you've offered, not what remains
- **Time-of-day arc** — the journey arc shifts colors with the time of day
- **Gentle onboarding** — calculate your debt automatically or enter numbers manually
- **iCloud sync** via SwiftData + CloudKit
- **No backend, no account, no notifications, no gamification**

## Design Philosophy

Calm, not clinical. Warm, not cold. Progress, not deficit. The app is a companion on a spiritual journey — not a spreadsheet of debt.

See [DESIGN.md](DESIGN.md) for the full design document.

## Tech Stack

- SwiftUI + SwiftData
- iOS 17+
- iCloud sync via CloudKit
- Fully on-device, no backend

## Building

Open `Prayer Debts.xcodeproj` in Xcode and run on a simulator or device.

## License

All rights reserved.
