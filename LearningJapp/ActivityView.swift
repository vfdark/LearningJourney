import SwiftUI
import Combine
import Foundation

// The view only DISPLAYS what the ViewModel gives it and forwards taps.
// No models, no database, no rules in here.

struct ActivityView: View {

    @State private var viewModel: ActivityViewModel
    @Environment(\.scenePhase) private var scenePhase

    /// Checks the time every 30 seconds (32 hour rule and 12 AM)
    private let ticker = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

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
                    statCards.padding(.top, 14)

                    Spacer()
                    logButton(size: circleSize)
                        .frame(maxWidth: .infinity)
                    Spacer()

                    VStack(spacing: 14) {
                        freezeButton(width: circleSize)

                        Text(viewModel.freezeCaption)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.todayStatus)
        // Keep the time-based rules fresh
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refresh() }
        }
        .onReceive(ticker) { _ in viewModel.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            viewModel.refresh()   // 12 AM: the buttons come back
        }
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

            // These two open other screens (calendar, edit goal). Built next.
            HStack(spacing: 10) {
                circleButton(icon: "calendar")
                circleButton(icon: "pencil.and.outline")
            }
        }
    }

    private func circleButton(icon: String) -> some View {
        Button {
            // opens another screen later
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

    // MARK: - Stat cards

    private var statCards: some View {
        HStack(spacing: 12) {
            statCard(icon: "flame.fill", tint: .stepOrange,
                     value: viewModel.learnedText, label: "Learned")
            statCard(icon: "snowflake", tint: .stepBlue,
                     value: viewModel.freezedText, label: "Freezed")
        }
    }

    private func statCard(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 20, weight: .bold))

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
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

    // MARK: - Freeze button

    @ViewBuilder
    private func freezeButton(width: CGFloat) -> some View {
        if viewModel.canFreeze {
            Button {
                viewModel.freeze()
            } label: {
                Text("Freeze for a day")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: width, height: 30)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.capsule)
            .tint(Color.stepBlue)
            .foregroundStyle(.white)
        } else {
            // Disabled: all freezes used, or today is already logged
            Button {} label: {
                Text("Freezed for a day")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: width, height: 30)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.capsule)
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
