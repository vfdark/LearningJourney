import SwiftUI

// MARK: - Duration model

enum LearningDuration: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}

// MARK: - Colors

extension Color {
    // #F09748 ("2 Orange" from the design)
    static let appOrange = Color(red: 240 / 255, green: 151 / 255, blue: 72 / 255)
}

// MARK: - Onboarding

struct OnboardingView: View {
    @State private var topic: String = ""
    @State private var duration: LearningDuration = .week
    @FocusState private var isTopicFocused: Bool

    var onStart: (String, LearningDuration) -> Void = { _, _ in }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

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
                    .submitLabel(.done)

                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 1)
                }
                .padding(.top, 36)

                // Duration chips (liquid glass)
                VStack(alignment: .leading, spacing: 16) {
                    Text("I want to learn it in a")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)

                    GlassEffectContainer(spacing: 12) {
                        HStack(spacing: 12) {
                            ForEach(LearningDuration.allCases) { option in
                                DurationChip(
                                    title: option.rawValue,
                                    isSelected: duration == option
                                ) {
                                    withAnimation(.smooth(duration: 0.25)) {
                                        duration = option
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 36)

                Spacer()

                // Start button (liquid glass)
                VStack(spacing: 12) {
                    Button {
                        onStart(topic, duration)
                    } label: {
                        Text("Start Learning")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .glassEffect(.regular.tint(Color.appOrange).interactive(), in: .capsule)
                    }
                    .buttonStyle(.plain)

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
        .onTapGesture { isTopicFocused = false }
    }
}

// MARK: - Chip

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.35))
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .glassEffect(
                    isSelected
                        ? .regular.tint(Color.appOrange).interactive()
                        : .regular.interactive(),
                    in: .capsule
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
}
