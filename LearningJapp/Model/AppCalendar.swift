import Foundation

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
