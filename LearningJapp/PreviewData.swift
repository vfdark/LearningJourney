import SwiftUI
import SwiftData

/// Temporary in-memory data for Xcode previews only (the canvas).
/// The running app never uses this: it uses the real database from LearningJappApp.
@MainActor
enum PreviewData {

    /// Kept in a static property so it stays alive as long as the preview.
    /// (If the container is a local variable, it is destroyed when the function ends,
    /// and the model crashes with "destroyed by calling ModelContext.reset".)
    private static let container: ModelContainer = {
        try! ModelContainer(
            for: Goal.self, DayEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }()

    static func activityViewModel() -> ActivityViewModel {
        let goal = Goal(topic: "Swift", duration: .week, streakStartKey: AppCalendar.key(for: Date()))
        container.mainContext.insert(goal)
        return ActivityViewModel(goal: goal, context: container.mainContext)
    }
}
