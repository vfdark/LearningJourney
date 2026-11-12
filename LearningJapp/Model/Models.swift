import Foundation
import SwiftData


// STEP 3: what the app saves on the phone.
// LearningDuration (Week / Month / Year) already lives in your Onboarding file.

// MARK: - Status of a logged day

enum DayStatus: String, Codable, Hashable {
    case learned
    case freezed
}

// MARK: - Goal (the thing the user wants to learn)

@Model
final class Goal {
    var topic: String               // "Swift"
    var durationRaw: String         // "Week", "Month" or "Year"
    var startDate: Date
    var lastActivity: Date?         // last learned day or freeze (used later for the 32 hour rule)
    var streakStartKey: String      // "2026-11-10": learned days from here count toward the streak

    // One goal has many logged days. Deleting the goal deletes its days too.
    @Relationship(deleteRule: .cascade, inverse: \DayEntry.goal)
    var days: [DayEntry] = []

    init(topic: String, duration: LearningDuration, startDate: Date = .now, streakStartKey: String) {
        self.topic = topic
        self.durationRaw = duration.rawValue
        self.startDate = startDate
        self.streakStartKey = streakStartKey
    }

    /// Turns the saved text back into a LearningDuration
    var duration: LearningDuration {
        LearningDuration(rawValue: durationRaw) ?? .week
    }
}

// MARK: - DayEntry (one logged day)

@Model
final class DayEntry {
    var dayKey: String              // "2026-11-10"
    var statusRaw: String           // "learned" or "freezed"
    var goal: Goal?                 // which goal this day belongs to

    init(dayKey: String, status: DayStatus) {
        self.dayKey = dayKey
        self.statusRaw = status.rawValue
    }

    var status: DayStatus {
        DayStatus(rawValue: statusRaw) ?? .learned
    }
}

// MARK: - Day key ("2026-11-10"): a new day = a new key, which is how 12 AM will work

enum AppCalendar {
    static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1
        return c
    }()

    static func key(for date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}
