import SwiftUI
import SwiftData

// Follows the user flow:
// Onboarding -> set learning goal and duration (saved) -> Activity page.
// No saved goal = Onboarding. A saved goal = Activity.

struct RootView: View {
    @Environment(\.modelContext) private var context

    // Reads every saved Goal from the database (newest first).
    // When a goal is saved, this list changes and SwiftUI switches the screen by itself.
    @Query(sort: \Goal.startDate, order: .reverse) private var goals: [Goal]

    var body: some View {
        if let goal = goals.first {
            // Task 1, last step: the Activity page
            ActivityView(viewModel: ActivityViewModel(goal: goal, context: context))
                .id(goal.persistentModelID) // a new goal gets a fresh screen
        } else {
            // Task 1, first step: Onboarding
            OnboardingView { topic, duration in
                // "Set learning goal and duration": save it
                let goal = Goal(
                    topic: topic,
                    duration: duration,
                    streakStartKey: AppCalendar.key(for: .now)
                )
                context.insert(goal)     // add it to the database
                try? context.save()      // write it to disk
            }
        }
    }
}

// Preview the WHOLE flow here (turn on Live mode in the canvas).
// It uses temporary data that disappears when the preview refreshes.
#Preview("Full flow") {
    RootView()
        .modelContainer(for: [Goal.self, DayEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
