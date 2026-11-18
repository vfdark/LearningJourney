import Foundation
import SwiftData

@Model
final class Goal {
    var topic: String                 // "Swift"
    var durationRaw: String           // "Week", "Month" or "Year"
    var startDate: Date
    var lastActivity: Date?           // last learned day or freeze
    var streakStartKey: String        // "2026-11-10"

    @Relationship(deleteRule: .cascade, inverse: \DayEntry.goal)
    var days: [DayEntry] = []

    init(topic: String, duration: LearningDuration, startDate: Date = .now, streakStartKey: String) {
        self.topic = topic
        self.durationRaw = duration.rawValue
        self.startDate = startDate
        self.streakStartKey = streakStartKey
    }

    var duration: LearningDuration {
        LearningDuration(rawValue: durationRaw) ?? .week
    }
}
