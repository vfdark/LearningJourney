import SwiftUI
import SwiftData

// STEP 1: background and header (title, today's real date, two round buttons)
// STEP 2: week strip (the real current week, today highlighted)
// STEP 3: receives the saved Goal and shows the freeze caption from it
// STEP 4: the big "Log as Learned" button, which saves a real day

struct ActivityView: View {

    /// The saved goal (comes from the database)
    let goal: Goal

    /// The database connection, used to save the logged day
    @Environment(\.modelContext) private var context

    // MARK: - Data

    /// Today's real date, e.g. "Tuesday, 10 November"
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }

    private let letters = ["S", "M", "T", "W", "T", "F", "S"]

    /// Gregorian calendar, week starts on Sunday (like the design)
    private var calendar: Calendar { AppCalendar.calendar }

    /// The 7 real days of the current week, Sunday to Saturday
    private var weekDays: [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    /// Saved status of any day (nil = nothing logged that day)
    private func status(on date: Date) -> DayStatus? {
        let key = AppCalendar.key(for: date)
        return goal.days.first(where: { $0.dayKey == key })?.status
    }

    private var todayStatus: DayStatus? { status(on: Date()) }

    /// The big button is disabled once today is logged as learned
    private var canLog: Bool { todayStatus != .learned }

    /// Freezes used so far = saved days whose status is "freezed"
    private var freezesUsed: Int {
        goal.days.filter { $0.status == .freezed }.count
    }

    // MARK: - Actions

    /// Saves today as a learned day
    private func logLearned() {
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

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let circleSize = min(geo.size.width * 0.7, 300)

            ZStack {
                // 1. Background fills the whole screen
                Color.stepBackground
                    .ignoresSafeArea()

                // 2. Everything else is stacked vertically on top of it
                VStack(alignment: .leading, spacing: 0) {
                    header
                    weekStrip.padding(.top, 14)

                    Spacer()
                    logButton(size: circleSize)
                        .frame(maxWidth: .infinity)
                    Spacer()

                    // 2 per week, 8 per month, 96 per year: read from the saved goal
                    Text("\(freezesUsed) out of \(goal.duration.freezeLimit) Freezes used")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .sensoryFeedback(.success, trigger: todayStatus)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {

            // Left side: title and date
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))

                Text(dateText)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right side: two round glass buttons
            HStack(spacing: 10) {
                circleButton(icon: "calendar")
                circleButton(icon: "pencil.and.outline")
            }
        }
    }

    // MARK: - Week strip

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                VStack(spacing: 8) {
                    Text(letters[index])
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)

                    dayCircle(for: date)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCircle(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let saved = status(on: date)

        // learned = orange number on a soft orange circle,
        // freezed = blue, today with nothing logged = solid orange
        let fill: Color = switch saved {
        case .learned: Color.stepOrange.opacity(0.18)
        case .freezed: Color.stepBlue.opacity(0.18)
        case nil: isToday ? Color.stepOrange : Color.clear
        }

        let textColor: Color = switch saved {
        case .learned: Color.stepOrange
        case .freezed: Color.stepBlue
        case nil: isToday ? Color.white : Color.primary
        }

        return Text(String(calendar.component(.day, from: date)))
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(textColor)
            .frame(width: 44, height: 44)
            .background(Circle().fill(fill))
    }

    private func circleButton(icon: String) -> some View {
        Button {
            // nothing yet: these open other screens later
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }

    // MARK: - Big Log button

    @ViewBuilder
    private func logButton(size: CGFloat) -> some View {
        if canLog {
            // Orange glass circle
            Button {
                logLearned()
            } label: {
                Text("Log as Learned")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: size, height: size)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(Color.stepOrange)
            .foregroundStyle(.white)
        } else {
            // Gray and disabled once today is logged
            Button {} label: {
                Text("Logged as Learned")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: size, height: size)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .foregroundStyle(Color.primary.opacity(0.3))
            .disabled(true)
        }
    }
}

// MARK: - Colors (light: system white, dark: #111111)

private extension Color {
    static let stepOrange = Color(red: 255 / 255, green: 146 / 255, blue: 48 / 255) // #FF9230
    static let stepBlue = Color(red: 0.38, green: 0.78, blue: 0.94)

    static let stepBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
            : .systemBackground
    })
}

#Preview {
    ActivityView(goal: Goal(topic: "Swift", duration: .week, streakStartKey: "2026-11-10"))
        .modelContainer(for: [Goal.self, DayEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
