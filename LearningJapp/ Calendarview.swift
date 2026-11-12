import SwiftUI

/// TASK 5: "Activities". View only, there is no interaction with the calendar.
struct CalendarView: View {

    @State private var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init(viewModel: CalendarViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.months) { month in
                            monthSection(month)

                            // Thin line between months
                            if month.id != viewModel.months.last?.id {
                                Rectangle()
                                    .fill(Color.primary.opacity(0.1))
                                    .frame(height: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear { viewModel.load() }
    }

    // MARK: - Top bar: back + title

    private var navigationBar: some View {
        ZStack {
            Text("Activities")
                .font(.system(size: 17, weight: .semibold))

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
        VStack(alignment: .leading, spacing: 10) {
            Text(month.title)
                .font(.system(size: 17, weight: .semibold))

            // SUN MON TUE ...
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            // The days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(month.cells.enumerated()), id: \.offset) { _, cell in
                    if let day = cell {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding(.vertical, 18)
    }

    // MARK: - One day

    private func dayCell(_ day: CalendarViewModel.Day) -> some View {
        // learned = orange on a soft orange circle, freezed = blue,
        // today with nothing logged = solid orange, other days = plain
        let fill: Color = switch day.status {
        case .learned: Color.appOrange.opacity(0.18)
        case .freezed: Color.appBlue.opacity(0.18)
        case nil: day.isToday ? Color.appOrange : Color.clear
        }

        let textColor: Color = switch day.status {
        case .learned: Color.appOrange
        case .freezed: Color.appBlue
        case nil: day.isToday ? Color.white : Color.primary
        }

        return Text(day.number)
            .font(.system(size: 18))
            .foregroundStyle(textColor)
            .frame(width: 40, height: 40)
            .background(Circle().fill(fill))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalendarView(viewModel: PreviewData.calendarViewModel())
        .preferredColorScheme(.dark)
}
