import SwiftUI
import Foundation

/// The "New Learning goal" screen: what the user is typing and whether it can be saved.
@MainActor
@Observable
final class GoalEditorViewModel {
    var topic: String = ""
    var duration: LearningDuration = .week

    var cleanedTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The button stays disabled until the user types what they want to learn
    var canSave: Bool { !cleanedTopic.isEmpty }
}
