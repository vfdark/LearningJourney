import SwiftUI
import Foundation

/// Onboarding logic: what the user typed and whether they can start.
@MainActor
@Observable
final class OnboardingViewModel {
    var topic: String = ""
    var duration: LearningDuration = .week

    var cleanedTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Start button is disabled until the user types what they want to learn
    var canStart: Bool { !cleanedTopic.isEmpty }
}
