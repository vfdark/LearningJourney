import SwiftUI
import SwiftData

/// Temporary in-memory data for Xcode previews only. Nothing here is saved on the phone.
@MainActor
enum PreviewData {
    static func activityViewModel() -> ActivityViewModel {
        let container = try! ModelContainer(
            for: Goal.self, DayEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let goal = Goal(topic: "Swift", duration: .week, streakStartKey: AppCalendar.key(for: Date()))
        container.mainContext.insert(goal)
        return ActivityViewModel(goal: goal, context: container.mainContext)
    }
}
