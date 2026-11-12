import SwiftUI

/// Task 1: Onboarding. Set the learning goal and duration.
/// The view only displays and forwards taps. The rules live in OnboardingViewModel.
struct OnboardingView: View {

    @State private var viewModel = OnboardingViewModel()
    @FocusState private var isTopicFocused: Bool

    /// Called with the topic and duration when the user taps "Start Learning"
    let onStart: (String, LearningDuration) -> Void

    init(onStart: @escaping (String, LearningDuration) -> Void) {
        self.onStart = onStart
    }

    var body: some View {
        ZStack {
            // Tap on the background closes the keyboard
            // (kept off the root view so it never blocks the buttons)
            Color.appBackground
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

                    Text("This app will help you learn everyday!")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 70)

                // Topic field
                VStack(alignment: .leading, spacing: 10) {
                    Text("I want to learn")
                        .font(.system(size: 18))

                    TextField(
                        "",
                        text: $viewModel.topic,
                        prompt: Text("Swift").foregroundColor(Color.primary.opacity(0.25))
                    )
                    .font(.system(size: 20))
                    .tint(Color.appOrange)
                    .focused($isTopicFocused)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .onSubmit { isTopicFocused = false }

                    Rectangle()
                        .fill(isTopicFocused ? Color.appOrange : Color.primary.opacity(0.15))
                        .frame(height: 1)
                        .animation(.easeInOut(duration: 0.2), value: isTopicFocused)
                }
                .padding(.top, 36)
                .contentShape(Rectangle())
                .onTapGesture { isTopicFocused = true }

                // Duration chips
                VStack(alignment: .leading, spacing: 16) {
                    Text("I want to learn it in a")
                        .font(.system(size: 18))

                    HStack(spacing: 12) {
                        ForEach(LearningDuration.allCases) { option in
                            DurationChip(
                                title: option.rawValue,
                                isSelected: viewModel.duration == option
                            ) {
                                isTopicFocused = false
                                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.15)) {
                                    viewModel.duration = option
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
                        onStart(viewModel.cleanedTopic, viewModel.duration)
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
                    .disabled(!viewModel.canStart)

                    Text("You can edit your desire later")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .sensoryFeedback(.selection, trigger: viewModel.duration)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTopicFocused = false }
                    .tint(Color.appOrange)
            }
        }
    }
}

#Preview {
    OnboardingView { topic, duration in
        print("Start:", topic, duration)
    }
    .preferredColorScheme(.dark)
}
