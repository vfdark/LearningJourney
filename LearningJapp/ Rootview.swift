import SwiftUI
import SwiftData

// Decides which screen to show:
// no saved goal -> Onboarding, saved goal -> Activity.

struct RootView: View {
    @Environment(\.modelContext) private var context

    // Reads every saved Goal from the database (newest first).
    // When the data changes, SwiftUI redraws this view by itself.
    @Query(sort: \Goal.startDate, order: .reverse) private var goals: [Goal]

    var body: some View {
        if let goal = goals.first {
            ActivityView(viewModel: ActivityViewModel(goal: goal, context: context))
                .id(goal.persistentModelID) // a new goal gets a fresh screen
        } else {
            OnboardingView { newGoal in
                let goal = Goal(
                    topic: newGoal.topic,
                    duration: newGoal.duration,
                    streakStartKey: AppCalendar.key(for: .now)
                )
                context.insert(goal)     // add it to the database
                try? context.save()      // write it to disk
            }
        }
    }
}
