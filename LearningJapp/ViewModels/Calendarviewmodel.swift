import SwiftUI
import SwiftData
import Foundation

/// TASK 5: the "Activities" screen. View only: it builds every month from the
/// beginning to today and marks each day as learned, freezed or empty.
@MainActor
@Observable
final class CalendarViewModel {

    /// One day in a month, ready to display
    struct Day: Identifiable {
        let id: String          // "2026-03-12"
        let number: String      // "12"
        let status: DayStatus?  // nil = nothing logged
        let isToday: Bool
    }

    /// One month block: "March 2026" and its day cells
    struct Month: Identifiable {
        let id: String          // "2026-03"
        let title: String       // "March 2026"
        let cells: [Day?]       // nil = empty slot before the 1st of the month
    }

    let weekdayHeaders = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    private(set) var months: [Month] = []

    private let context: ModelContext
    private let now: Date
    private let calendar = AppCalendar.calendar

    private static let monthNames = ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]

    init(context: ModelContext, now: Date = .now) {
        self.context = context
        self.now = now
    }

    // MARK: - Load

    /// Reads every saved day (from every goal) and builds the months, oldest first.
    func load() {
        let goals = (try? context.fetch(FetchDescriptor<Goal>())) ?? []
        let entries = (try? context.fetch(FetchDescriptor<DayEntry>())) ?? []

        // dayKey -> status. If two goals logged the same day, "learned" wins.
        var statusByKey: [String: DayStatus] = [:]
        for entry in entries {
            if statusByKey[entry.dayKey] == .learned { continue }
            statusByKey[entry.dayKey] = entry.status
        }

        // From the month of the very first goal until the current month
        let earliest = goals.map(\.startDate).min() ?? now
        let currentMonth = startOfMonth(now)
        var cursor = startOfMonth(min(earliest, now))

        var result: [Month] = []
        while cursor <= currentMonth {
            result.append(makeMonth(starting: cursor, statuses: statusByKey))
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        months = result
    }

    // MARK: - Private

    private func startOfMonth(_ date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private func makeMonth(starting monthStart: Date, statuses: [String: DayStatus]) -> Month {
        let parts = calendar.dateComponents([.year, .month], from: monthStart)
        let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        // Empty slots so the 1st lands under the right weekday (Sunday first)
        let leading = max(0, calendar.component(.weekday, from: monthStart) - 1)
        var cells: [Day?] = Array(repeating: nil, count: leading)

        for offset in 0..<dayCount {
            guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { continue }
            let key = AppCalendar.key(for: date)
            cells.append(Day(
                id: key,
                number: String(offset + 1),
                status: statuses[key],
                isToday: calendar.isDate(date, inSameDayAs: now)
            ))
        }

        let monthName = Self.monthNames[((parts.month ?? 1) - 1) % 12]
        return Month(
            id: String(format: "%04d-%02d", parts.year ?? 0, parts.month ?? 0),
            title: "\(monthName) \(parts.year ?? 0)",
            cells: cells
        )
    }
}
