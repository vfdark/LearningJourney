import Foundation
import SwiftData

@Model
final class DayEntry {
    var dayKey: String              // "2026-11-10"
    var statusRaw: String           // "learned" or "freezed"
    var loggedAt: Date?             // when it was logged
    var goal: Goal?                 // which goal this day belongs to

    init(dayKey: String, status: DayStatus) {
        self.dayKey = dayKey
        self.statusRaw = status.rawValue
    }

    var status: DayStatus {
        DayStatus(rawValue: statusRaw) ?? .learned
    }
}
