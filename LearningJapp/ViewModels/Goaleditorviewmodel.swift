import SwiftUI
import Foundation

/// The "Learning Goal" screen: what the user is typing, whether it can be saved,
/// and whether the "Update goal" alert is showing.
@MainActor
@Observable
final class GoalEditorViewModel {
    var topic: String
    var duration: LearningDuration
    var showAlert = false

    /// true = ask "If you update now, your streak will start over" before saving
    let requiresConfirmation: Bool

    private let initialTopic: String
    private let initialDuration: LearningDuration

    init(topic: String = "", duration: LearningDuration = .week, requiresConfirmation: Bool = true) {
        self.topic = topic
        self.duration = duration
        self.initialTopic = topic
        self.initialDuration = duration
        self.requiresConfirmation = requiresConfirmation
    }

    var cleanedTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Did the user change the topic or the duration?
    var hasChanges: Bool {
        cleanedTopic != initialTopic || duration != initialDuration
    }

    /// The check button is disabled until there is a topic and something changed
    var canSave: Bool { !cleanedTopic.isEmpty && hasChanges }
}
