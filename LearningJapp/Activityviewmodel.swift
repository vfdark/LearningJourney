import SwiftUI
import SwiftData
import Foundation

/// The brain of the Activity screen: it reads the saved Goal and DayEntry models,
/// applies the app rules, and gives the view ready-to-show values.
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

    /// TASK 3: where the goal stands
    enum GoalOutcome {
        case inProgress   // keep logging
        case completed    // "Well done!"
        case notMet       // "You didn't reach your goal this time."
    }

    private let goal: Goal
    private let context: ModelContext
    private let calendar = AppCalendar.calendar
    private let letters = ["S", "M", "T", "W", "T", "F", "S"]

    /// 32 hours without logging resets the streak.
    /// To test quickly, temporarily change it to 2 * 60 (2 minutes).
    private static let streakWindow: TimeInterval = 32 * 60 * 60

    /// "Now" as the screen knows it. refresh() updates it (app opens, every 30 s, at 12 AM).
    private(set) var now: Date

    init(goal: Goal, context: ModelContext, now: Date = .now) {
        self.goal = goal
        self.context = context
        self.now = now
        applyStreakRules()
    }

    // MARK: - Header

    /// Current goal, used to fill the "Learning Goal" screen
    var goalTopic: String { goal.topic }
    var goalDuration: LearningDuration { goal.duration }

    /// Today's real date, e.g. "Tuesday, 10 November"
    var dateText: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: now)
    }

    // MARK: - Week strip

    /// The 7 real days of the current week, Sunday to Saturday
    var weekDays: [WeekDay] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return WeekDay(
                id: offset,
                letter: letters[offset],
                number: String(calendar.component(.day, from: date)),
                status: status(on: date),
                isToday: calendar.isDate(date, inSameDayAs: now)
            )
        }
    }

    // MARK: - Counts (all read from the saved days)

    /// Learned days in the current streak (resets after 32 hours without a log, or when the goal changes)
    var streakCount: Int {
        goal.days.filter { $0.status == .learned && $0.dayKey >= goal.streakStartKey }.count
    }

    var freezesUsed: Int {
        goal.days.filter { $0.status == .freezed }.count
    }

    /// 2 per week, 8 per month, 96 per year
    var freezeLimit: Int { goal.duration.freezeLimit }

    // MARK: - Texts (wording rule: 1 -> "Day", otherwise "days")

    var learnedText: String { Self.dayCount(streakCount) }
    var freezedText: String { Self.dayCount(freezesUsed) }
    var freezeCaption: String { "\(freezesUsed) out of \(freezeLimit) Freezes used" }

    static func dayCount(_ n: Int) -> String {
        n == 1 ? "1 Day" : "\(n) days"
    }

    // MARK: - TASK 3: goal completed or not met

    /// Days needed to complete the goal: 7 for a week, 30 for a month, 365 for a year
    private var targetDays: Int { goal.duration.targetDays }

    /// Every logged day counts (learned or freezed)
    private var loggedDays: Int { goal.days.count }

    /// Key of the last day of the goal: start day + (targetDays - 1) days
    private var lastDayKey: String {
        let start = calendar.startOfDay(for: goal.startDate)
        let end = calendar.date(byAdding: .day, value: targetDays - 1, to: start) ?? start
        return AppCalendar.key(for: end)
    }

    var outcome: GoalOutcome {
        if loggedDays >= targetDays { return .completed }      // reached the goal
        if todayKey > lastDayKey { return .notMet }            // time is over, goal not reached
        return .inProgress
    }

    var resultIcon: String {
        outcome == .completed ? "hands.clap.fill" : "xmark.seal"
    }

    var resultTitle: String {
        outcome == .completed ? "Well done!" : "You didn't reach your goal this time."
    }

    var resultSubtitle: String {
        outcome == .completed ? "Ready for your next goal?" : "Want to set another goal?"
    }

    // MARK: - Button states

    var todayKey: String { AppCalendar.key(for: now) }

    var todayStatus: DayStatus? { status(on: now) }

    /// Disabled once today is logged as learned. Enabled again at 12 AM,
    /// because a new day has a new key and nothing is saved under it yet.
    var canLog: Bool { outcome == .inProgress && todayStatus != .learned }

    /// Disabled if all freezes are used OR today is already logged.
    var canFreeze: Bool { outcome == .inProgress && todayStatus == nil && freezesUsed < freezeLimit }

    // MARK: - Time

    /// Call when the app becomes active, at midnight and on a timer.
    func refresh(now: Date = .now) {
        self.now = now
        applyStreakRules()
    }

    /// Streak resets if nothing (learned day or freeze) was logged for more than 32 hours.
    private func applyStreakRules() {
        guard let last = goal.lastActivity else { return }
        if now.timeIntervalSince(last) > Self.streakWindow {
            goal.streakStartKey = AppCalendar.key(for: now)  // learned days before this no longer count
            goal.lastActivity = nil
            save()
        }
    }

    // MARK: - Actions

    func logLearned() {
        refresh()
        guard canLog else { return }
        setToday(.learned)   // also replaces a freeze made earlier today
    }

    func freeze() {
        refresh()
        guard canFreeze else { return }
        setToday(.freezed)   // a freeze keeps the streak alive
    }

    /// TASK 3: "Set a goal". Saves a brand new goal. The old goal stays in the database,
    /// and the app shows the newest goal, so the user lands on a fresh Activity screen.
    func startNewGoal(topic: String, duration: LearningDuration) {
        let cleaned = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        let newGoal = Goal(
            topic: cleaned,
            duration: duration,
            startDate: now,
            streakStartKey: AppCalendar.key(for: now)
        )
        context.insert(newGoal)
        save()
    }

    /// TASK 4: "Update goal". The streak, freezes and progress start over,
    /// so it is saved as a fresh goal (the old one stays in the database).
    func updateGoal(topic: String, duration: LearningDuration) {
        startNewGoal(topic: topic, duration: duration)
    }

    // MARK: - Private

    private func status(on date: Date) -> DayStatus? {
        let key = AppCalendar.key(for: date)
        return goal.days.first(where: { $0.dayKey == key })?.status
    }

    /// Saves today's status in the database and restarts the 32 hour clock
    private func setToday(_ status: DayStatus) {
        let key = AppCalendar.key(for: now)

        if let existing = goal.days.first(where: { $0.dayKey == key }) {
            existing.statusRaw = status.rawValue
        } else {
            let entry = DayEntry(dayKey: key, status: status)
            context.insert(entry)
            entry.goal = goal
        }

        goal.lastActivity = now
        save()
    }

    private func save() {
        try? context.save()
    }
}
