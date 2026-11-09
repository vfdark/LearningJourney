import SwiftUI

// Uses `Color.appOrange` and `LearningDuration` from OnboardingView.swift

// MARK: - Colors

extension Color {
    static let freezeBlue = Color(red: 0.38, green: 0.78, blue: 0.94)
}

// MARK: - Model

enum DayStatus {
    case learned
    case freezed
}

@Observable
final class ActivityViewModel {
    var today: Date
    var log: [Date: DayStatus]
    var duration: LearningDuration

    private var calendar: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 1 // Sunday, like the design
        return c
    }()

    init(today: Date = .now,
         log: [Date: DayStatus] = [:],
         duration: LearningDuration = .week) {
        self.today = today
        self.duration = duration
        var normalized: [Date: DayStatus] = [:]
        let cal = Calendar.current
        for (date, status) in log { normalized[cal.startOfDay(for: date)] = status }
        self.log = normalized
    }

    // MARK: Derived state

    var todayStatus: DayStatus? { log[calendar.startOfDay(for: today)] }

    /// Freeze limits: 2 per week, 8 per month, 96 per year
    var freezeLimit: Int {
        switch duration {
        case .week: 2
        case .month: 8
        case .year: 96
        }
    }

    var learnedCount: Int { log.values.filter { $0 == .learned }.count }
    var freezedCount: Int { log.values.filter { $0 == .freezed }.count }

    /// Log button is disabled once today is already logged as learned
    var canLog: Bool { todayStatus != .learned }

    /// Freeze button is disabled if today is logged or all freezes are used
    var canFreeze: Bool { todayStatus == nil && freezedCount < freezeLimit }

    var weekDays: [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    func status(for date: Date) -> DayStatus? { log[calendar.startOfDay(for: date)] }
    func isToday(_ date: Date) -> Bool { calendar.isDate(date, inSameDayAs: today) }
    func dayNumber(_ date: Date) -> String { String(calendar.component(.day, from: date)) }

    // MARK: Actions

    func logLearned() {
        guard canLog else { return }
        log[calendar.startOfDay(for: today)] = .learned
    }

    func freeze() {
        guard canFreeze else { return }
        log[calendar.startOfDay(for: today)] = .freezed
    }
}

// MARK: - Screen

struct ActivityView: View {
    @State private var model: ActivityViewModel

    var onCalendar: () -> Void = {}
    var onEditGoal: () -> Void = {}

    init(model: ActivityViewModel = ActivityViewModel(),
         onCalendar: @escaping () -> Void = {},
         onEditGoal: @escaping () -> Void = {}) {
        _model = State(initialValue: model)
        self.onCalendar = onCalendar
        self.onEditGoal = onEditGoal
    }

    private let letters = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        GeometryReader { geo in
            let circleSize = min(geo.size.width * 0.7, 300)

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    header
                    weekStrip.padding(.top, 14)
                    statCards.padding(.top, 14)

                    Spacer()
                    logButton(size: circleSize)
                        .frame(maxWidth: .infinity)
                    Spacer()

                    VStack(spacing: 14) {
                        freezeButton(width: circleSize)
                        Text("\(model.freezedCount) out of \(model.freezeLimit) Freezes used")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.success, trigger: model.todayStatus)
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            // Re-enables the buttons at 12 AM
            model.today = .now
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                Text(model.today.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: onCalendar) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)

                Button(action: onEditGoal) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 18))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }
            .foregroundStyle(.white)
        }
    }

    // MARK: Week strip

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(Array(model.weekDays.enumerated()), id: \.offset) { index, date in
                DayCell(
                    letter: letters[index],
                    number: model.dayNumber(date),
                    status: model.status(for: date),
                    isToday: model.isToday(date)
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Stat cards

    private var statCards: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "flame.fill",
                tint: .appOrange,
                value: countText(model.learnedCount),
                label: "Learned"
            )
            StatCard(
                icon: "snowflake",
                tint: .freezeBlue,
                value: countText(model.freezedCount),
                label: "Freezed"
            )
        }
    }

    /// 1 -> "1 Day", otherwise "N days"
    private func countText(_ n: Int) -> String {
        n == 1 ? "1 Day" : "\(n) days"
    }

    // MARK: Buttons

    @ViewBuilder
    private func logButton(size: CGFloat) -> some View {
        if model.canLog {
            Button { model.logLearned() } label: {
                Text("Log as Learned")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: size, height: size)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(Color.appOrange)
            .foregroundStyle(.white)
        } else {
            Button {} label: {
                Text("Logged as Learned")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: size, height: size)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .foregroundStyle(Color.white.opacity(0.3))
            .disabled(true)
        }
    }

    @ViewBuilder
    private func freezeButton(width: CGFloat) -> some View {
        if model.canFreeze {
            Button { model.freeze() } label: {
                Text("Freeze for a day")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: width, height: 30)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.capsule)
            .tint(Color.freezeBlue)
            .foregroundStyle(.white)
        } else {
            Button {} label: {
                Text("Freezed for a day")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: width, height: 30)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.capsule)
            .foregroundStyle(Color.white.opacity(0.3))
            .disabled(true)
        }
    }
}

// MARK: - Day cell

struct DayCell: View {
    let letter: String
    let number: String
    let status: DayStatus?
    let isToday: Bool

    private var fill: Color {
        switch status {
        case .learned: Color.appOrange.opacity(0.18)
        case .freezed: Color.freezeBlue.opacity(0.18)
        case nil: isToday ? Color.appOrange : .clear
        }
    }

    private var textColor: Color {
        switch status {
        case .learned: Color.appOrange
        case .freezed: Color.freezeBlue
        case nil: .white
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(letter)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.55))

            Text(number)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(textColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(fill))
        }
    }
}

// MARK: - Stat card

struct StatCard: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}

// MARK: - Previews (the four states from the design)

private func previewDate(_ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: day))!
}

private func previewModel(learned: [Int], freezed: [Int]) -> ActivityViewModel {
    var log: [Date: DayStatus] = [:]
    learned.forEach { log[previewDate($0)] = .learned }
    freezed.forEach { log[previewDate($0)] = .freezed }
    return ActivityViewModel(today: previewDate(24), log: log)
}

#Preview("Current day - Default") {
    ActivityView(model: previewModel(learned: [20, 21, 22, 23], freezed: []))
}

#Preview("Learned today") {
    ActivityView(model: previewModel(learned: [20, 21, 22, 23, 24], freezed: []))
}

#Preview("Freezed today") {
    ActivityView(model: previewModel(learned: [20, 21, 22, 23], freezed: [24]))
}

#Preview("No Freezes available") {
    ActivityView(model: previewModel(learned: [20, 21, 22], freezed: [23, 24]))
}
