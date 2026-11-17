import SwiftUI
import SwiftData
import Foundation

/// TASK 5: the "Activities" screen. View only: it builds every month from the
/// beginning of the year to December and marks each day as learned, freezed or empty.
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

    /// How many saved days and goals were found (shown in a small debug line while testing)
    private(set) var savedDayCount = 0
    private(set) var goalCount = 0

    private let context: ModelContext
    private let now: Date
    private let calendar = AppCalendar.calendar

    private static let monthNames = ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]

    init(context: ModelContext, now: Date = .now) {
        self.context = context
        self.now = now
        load()   // the months exist from the very first frame
    }

    /// Id of the month that contains today, e.g. "2026-11". The screen scrolls to it.
    var currentMonthID: String {
        let parts = calendar.dateComponents([.year, .month], from: now)
        return String(format: "%04d-%02d", parts.year ?? 0, parts.month ?? 0)
    }

    // MARK: - Load

    /// Reads every saved day (from every goal) and builds the months, oldest first.
    func load() {
        let goals = (try? context.fetch(FetchDescriptor<Goal>())) ?? []
        let entries = (try? context.fetch(FetchDescriptor<DayEntry>())) ?? []
        goalCount = goals.count
        savedDayCount = entries.count

        // dayKey -> status. If two goals logged the same day, "learned" wins.
        var statusByKey: [String: DayStatus] = [:]
        for entry in entries {
            if statusByKey[entry.dayKey] == .learned { continue }
            statusByKey[entry.dayKey] = entry.status
        }

        // The WHOLE year: January to December. If the first goal started in an earlier year,
        // the calendar starts from January of that year.
        let earliest = goals.map(\.startDate).min() ?? now
        let firstYear = calendar.component(.year, from: min(earliest, now))
        let currentYear = calendar.component(.year, from: now)

        let firstMonth = calendar.date(from: DateComponents(year: firstYear, month: 1, day: 1)) ?? startOfMonth(now)
        let lastMonth = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 1)) ?? startOfMonth(now)

        var cursor = firstMonth
        var result: [Month] = []
        while cursor <= lastMonth {
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
