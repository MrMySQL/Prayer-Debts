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
