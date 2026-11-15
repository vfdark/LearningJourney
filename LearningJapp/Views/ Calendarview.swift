import SwiftUI

/// TASK 5: "Activities". View only, there is no interaction with the calendar.
/// It opens at the month you are in, and today is marked.
struct CalendarView: View {

    @State private var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    /// 7 equal columns, Sunday first
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init(viewModel: CalendarViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.months) { month in
                            VStack(alignment: .leading, spacing: 0) {
                                monthSection(month)

                                // Thin line between months
                                if month.id != viewModel.months.last?.id {
                                    Rectangle()
                                        .fill(Color.primary.opacity(0.1))
                                        .frame(height: 1)
                                }
                            }
                            .id(month.id)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                // The days scroll under the top bar, like the design
                .scrollEdgeEffectStyle(.soft, for: .top)
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 4) {
                        navigationBar

                        #if DEBUG
                        // Testing only: how much data the calendar found. Not shown in a release build.
                        Text("debug: \(viewModel.savedDayCount) saved days, \(viewModel.goalCount) goals")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        #endif
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                // Jump to the month you are in
                .onAppear {
                    viewModel.load()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(viewModel.currentMonthID, anchor: .top)
                    }
                }
            }
        }
    }

    // MARK: - Top bar: back + title

    private var navigationBar: some View {
        ZStack {
            Text("Activities")
                .font(.system(size: 16, weight: .semibold))

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)

                Spacer()
            }
        }
    }

    // MARK: - One month

    private func monthSection(_ month: CalendarViewModel.Month) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // "January 2026"
            Text(month.title)
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal, 10)

            // SUN MON TUE ...
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.4)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 14)

            // The days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(month.cells.enumerated()), id: \.offset) { _, cell in
                    if let day = cell {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 41)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - One day

    private func dayCell(_ day: CalendarViewModel.Day) -> some View {
        // learned = orange number on a soft orange circle, freezed = blue on a soft blue circle,
        // today with nothing logged = solid orange, other days = plain. No outline.
        let isLoggedToday = day.isToday && day.status != nil

        let fill: Color = switch day.status {
        case .learned: Color.appOrange.opacity(isLoggedToday ? 0.32 : 0.18)
        case .freezed: Color.appBlue.opacity(isLoggedToday ? 0.32 : 0.18)
        case nil: day.isToday ? Color.appOrange : Color.clear
        }

        let textColor: Color = switch day.status {
        case .learned: Color.appOrange
        case .freezed: Color.appBlue
        case nil: day.isToday ? Color.white : Color.primary
        }

        return Text(day.number)
            .font(.system(size: 19, weight: isLoggedToday ? .semibold : .regular))
            .foregroundStyle(textColor)
            .frame(width: 41, height: 41)
            .background(Circle().fill(fill))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalendarView(viewModel: PreviewData.calendarViewModel())
        .preferredColorScheme(.dark)
}
