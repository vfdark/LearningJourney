import SwiftUI

// The view only DISPLAYS what the ViewModel gives it and forwards taps.
// No models, no database, no rules in here.

struct ActivityView: View {

    @State private var viewModel: ActivityViewModel

    init(viewModel: ActivityViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        GeometryReader { geo in
            let circleSize = min(geo.size.width * 0.7, 300)

            ZStack {
                Color.stepBackground
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    header
                    weekStrip.padding(.top, 14)

                    Spacer()
                    logButton(size: circleSize)
                        .frame(maxWidth: .infinity)
                    Spacer()

                    Text("\(viewModel.freezesUsed) out of \(viewModel.freezeLimit) Freezes used")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.todayStatus)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))

                Text(viewModel.dateText)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 10) {
                circleButton(icon: "calendar")
                circleButton(icon: "pencil.and.outline")
            }
        }
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

    // MARK: - Week strip

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDays) { day in
                VStack(spacing: 8) {
                    Text(day.letter)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)

                    dayCircle(day)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCircle(_ day: ActivityViewModel.WeekDay) -> some View {
        // learned = orange number on a soft orange circle,
        // freezed = blue, today with nothing logged = solid orange
        let fill: Color = switch day.status {
        case .learned: Color.stepOrange.opacity(0.18)
        case .freezed: Color.stepBlue.opacity(0.18)
        case nil: day.isToday ? Color.stepOrange : Color.clear
        }

        let textColor: Color = switch day.status {
        case .learned: Color.stepOrange
        case .freezed: Color.stepBlue
        case nil: day.isToday ? Color.white : Color.primary
        }

        return Text(day.number)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(textColor)
            .frame(width: 44, height: 44)
            .background(Circle().fill(fill))
    }

    // MARK: - Big Log button

    @ViewBuilder
    private func logButton(size: CGFloat) -> some View {
        if viewModel.canLog {
            Button {
                viewModel.logLearned()
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
    ActivityView(viewModel: PreviewData.activityViewModel())
        .preferredColorScheme(.dark)
}
