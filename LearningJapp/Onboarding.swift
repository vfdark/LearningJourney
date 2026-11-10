import SwiftUI

// MARK: - Goal model (what onboarding produces)

enum LearningDuration: String, CaseIterable, Identifiable, Codable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    /// Freezes allowed: 2 per week, 8 per month, 96 per year
    var freezeLimit: Int {
        switch self {
        case .week: 2
        case .month: 8
        case .year: 96
        }
    }

    /// How many days the goal lasts
    var targetDays: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }
}

struct LearningGoal: Codable, Equatable {
    var topic: String
    var duration: LearningDuration
}

// MARK: - Colors

extension Color {
    static let appOrange = Color(red: 255 / 255, green: 146 / 255, blue: 48 / 255) // #FF9230
}

// MARK: - Onboarding

struct OnboardingView: View {
    @State private var topic: String = ""
    @State private var duration: LearningDuration = .week
    @FocusState private var isTopicFocused: Bool

    /// Called when the user taps "Start Learning" with a valid goal
    var onStart: (LearningGoal) -> Void = { _ in }

    private var cleanedTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Start button is disabled until the user types what they want to learn
    private var canStart: Bool { !cleanedTopic.isEmpty }

    var body: some View {
        ZStack {
            // Tap on the background dismisses the keyboard
            // (kept off the root view so it never blocks the buttons)
            Color.black
                .ignoresSafeArea()
                .onTapGesture { isTopicFocused = false }

            VStack(alignment: .leading, spacing: 0) {

                // Flame icon
                HStack {
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appOrange)
                    Spacer()
                }
                .padding(.top, 60)

                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    (Text("Hello ").fontWeight(.regular) + Text("Learner").fontWeight(.bold))
                        .font(.system(size: 38))
                        .foregroundStyle(.white)

                    Text("This app will help you learn everyday!")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                .padding(.top, 70)

                // Topic field
                VStack(alignment: .leading, spacing: 10) {
                    Text("I want to learn")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)

                    TextField(
                        "",
                        text: $topic,
                        prompt: Text("Swift").foregroundColor(Color.white.opacity(0.25))
                    )
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .tint(Color.appOrange)
                    .focused($isTopicFocused)
                    .keyboardType(.default)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .onSubmit { isTopicFocused = false }

                    Rectangle()
                        .fill(isTopicFocused ? Color.appOrange : Color.white.opacity(0.15))
                        .frame(height: 1)
                        .animation(.easeInOut(duration: 0.2), value: isTopicFocused)
                }
                .padding(.top, 36)
                // Tapping anywhere on the label / field / underline opens the keyboard
                .contentShape(Rectangle())
                .onTapGesture { isTopicFocused = true }

                // Duration chips
                VStack(alignment: .leading, spacing: 16) {
                    Text("I want to learn it in a")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        ForEach(LearningDuration.allCases) { option in
                            DurationChip(
                                title: option.rawValue,
                                isSelected: duration == option
                            ) {
                                isTopicFocused = false
                                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.15)) {
                                    duration = option
                                }
                            }
                        }
                    }
                }
                .padding(.top, 36)

                Spacer()

                // Start button
                VStack(spacing: 12) {
                    Button {
                        isTopicFocused = false
                        onStart(LearningGoal(topic: cleanedTopic, duration: duration))
                    } label: {
                        Text("Start Learning")
                            .font(.system(size: 20, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .tint(Color.appOrange)
                    .foregroundStyle(.white)
                    .disabled(!canStart)

                    Text("You can edit your desire later")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.selection, trigger: duration)
        // "Done" button above the iOS keyboard
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTopicFocused = false }
                    .tint(Color.appOrange)
            }
        }
    }
}

// MARK: - Duration chip

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        // One single button (same view identity for selected and unselected),
        // only the tint and text color change.
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(isSelected ? Color.appOrange : Color(white: 0.16))
        .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.45))
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    OnboardingView { goal in
        print("Start:", goal)
    }
}
