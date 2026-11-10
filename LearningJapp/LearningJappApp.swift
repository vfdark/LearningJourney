import SwiftUI
import SwiftData

@main
struct LearningJappApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Goal.self, DayEntry.self])
    }
}
