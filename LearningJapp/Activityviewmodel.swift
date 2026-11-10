import SwiftUI
import SwiftData

/// Everything the Activity screen knows and does. The view only displays this.
@MainActor
@Observable
final class ActivityViewModel {

    /// One day of the week strip, ready to display
    struct WeekDay: Identifiable {
        let id: Int
        let letter: String      // "S", "M", ...
        let number: String      // "10"
        let status: DayStatus?  // nil = nothing logged
        let isToday: Bool
    }

    private let goal: Goal
    private let context: ModelContext
    private let calendar = AppCalendar.calendar
    private let letters = ["S", "M", "T", "W", "T", "F", "S"]

    init(goal: Goal, context: ModelContext) {
        self.goal = goal
        self.context = context
    }

    // MARK: - What the screen shows

    /// Today's real date, e.g. "Tuesday, 10 November"
    var dateText: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }

    /// The 7 real days of the current week, Sunday to Saturday
    var weekDays: [WeekDay] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return WeekDay(
                id: offset,
                letter: letters[offset],
                number: String(calendar.component(.day, from: date)),
                status: status(on: date),
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    var todayStatus: DayStatus? { status(on: Date()) }

    /// The big button is disabled once today is logged as learned
    var canLog: Bool { todayStatus != .learned }

    /// Freezes used so far = saved days whose status is "freezed"
    var freezesUsed: Int {
        goal.days.filter { $0.status == .freezed }.count
    }

    /// 2 per week, 8 per month, 96 per year
    var freezeLimit: Int { goal.duration.freezeLimit }

    // MARK: - Actions

    /// Saves today as a learned day
    func logLearned() {
        guard canLog else { return }
        let key = AppCalendar.key(for: Date())

        if let existing = goal.days.first(where: { $0.dayKey == key }) {
            existing.statusRaw = DayStatus.learned.rawValue
        } else {
            let entry = DayEntry(dayKey: key, status: .learned)
            context.insert(entry)
            entry.goal = goal
        }

        goal.lastActivity = Date()
        try? context.save()
    }

    // MARK: - Private

    private func status(on date: Date) -> DayStatus? {
        let key = AppCalendar.key(for: date)
        return goal.days.first(where: { $0.dayKey == key })?.status
    }
}
