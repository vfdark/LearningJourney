import SwiftUI
import SwiftData

/// Temporary in-memory data for Xcode previews only (the canvas).
/// The running app never uses this: it uses the real database from LearningJappApp.
@MainActor
enum PreviewData {

    /// Kept in a static property so it stays alive as long as the preview.
    private static let container: ModelContainer = {
        try! ModelContainer(
            for: Goal.self, DayEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }()

    /// Builds a screen in a given state, using days counted back from today.
    static func activityViewModel(today: DayStatus? = nil,
                                  pastLearned: Int = 0,
                                  pastFreezed: Int = 0,
                                  duration: LearningDuration = .week,
                                  startedDaysAgo: Int? = nil) -> ActivityViewModel {
        let cal = AppCalendar.calendar
        let now = Date()
        let context = container.mainContext

        let daysBack = startedDaysAgo ?? (pastLearned + pastFreezed)
        let start = cal.date(byAdding: .day, value: -daysBack, to: now) ?? now
        let goal = Goal(topic: "Swift", duration: duration, startDate: start,
                        streakStartKey: AppCalendar.key(for: start))
        context.insert(goal)
        goal.lastActivity = now.addingTimeInterval(-3600)

        func add(_ status: DayStatus, daysAgo: Int) {
            guard let date = cal.date(byAdding: .day, value: -daysAgo, to: now) else { return }
            let entry = DayEntry(dayKey: AppCalendar.key(for: date), status: status)
            context.insert(entry)
            entry.goal = goal
        }

        var daysAgo = 1
        for _ in 0..<pastLearned { add(.learned, daysAgo: daysAgo); daysAgo += 1 }
        for _ in 0..<pastFreezed { add(.freezed, daysAgo: daysAgo); daysAgo += 1 }
        if let today { add(today, daysAgo: 0) }

        return ActivityViewModel(goal: goal, context: context)
    }
}
