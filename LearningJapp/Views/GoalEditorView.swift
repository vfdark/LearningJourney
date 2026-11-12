import SwiftUI

/// "Learning Goal" screen. Used to update the current goal (pencil button)
/// and to set a new goal when the old one ended ("Set a goal" button).
struct GoalEditorView: View {

    @State private var viewModel: GoalEditorViewModel
    @FocusState private var isTopicFocused: Bool
    @Environment(\.dismiss) private var dismiss

    /// Called with the topic and duration once the user confirms
    let onSave: (String, LearningDuration) -> Void

    init(topic: String = "",
         duration: LearningDuration = .week,
         requiresConfirmation: Bool = true,
         onSave: @escaping (String, LearningDuration) -> Void) {
        _viewModel = State(initialValue: GoalEditorViewModel(
            topic: topic,
            duration: duration,
            requiresConfirmation: requiresConfirmation
        ))
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
                .onTapGesture { isTopicFocused = false }

            VStack(alignment: .leading, spacing: 0) {
                navigationBar
                topicField
                durationChips
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // The "Update goal" alert, on top of everything
            if viewModel.showAlert {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { closeAlert() }

                updateAlert
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
        .sensoryFeedback(.selection, trigger: viewModel.duration)
    }

    // MARK: - Top bar: back, title, check

    private var navigationBar: some View {
        ZStack {
            Text("Learning Goal")
                .font(.system(size: 17, weight: .semibold))

            HStack {
                // Back
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

                // Check (confirm)
                Button {
                    checkTapped()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .tint(Color.appOrange)
                .foregroundStyle(.white)
                .disabled(!viewModel.canSave)
            }
        }
    }

    // MARK: - Topic

    private var topicField: some View {
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
        .padding(.top, 48)
        .contentShape(Rectangle())
        .onTapGesture { isTopicFocused = true }
    }

    // MARK: - Duration

    private var durationChips: some View {
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
    }

    // MARK: - Alert: "Update goal"

    private var updateAlert: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Update goal")
                .font(.system(size: 17, weight: .bold))

            Text("If you update now, your streak will start over.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    closeAlert()
                } label: {
                    Text("Dismiss")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .foregroundStyle(.primary)

                Button {
                    save()
                } label: {
                    Text("Update")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .tint(Color.appOrange)
                .foregroundStyle(.white)
            }
            .padding(.top, 14)
        }
        .padding(22)
        .frame(width: 310)
        .glassEffect(.regular, in: .rect(cornerRadius: 32))
    }

    // MARK: - Actions

    private func checkTapped() {
        isTopicFocused = false
        if viewModel.requiresConfirmation {
            withAnimation(.spring(duration: 0.3)) { viewModel.showAlert = true }
        } else {
            save()
        }
    }

    private func closeAlert() {
        withAnimation(.spring(duration: 0.25)) { viewModel.showAlert = false }
    }

    private func save() {
        onSave(viewModel.cleanedTopic, viewModel.duration)
        dismiss()
    }
}

#Preview("Update goal") {
    GoalEditorView(topic: "Swift", duration: .week) { topic, duration in
        print("Update:", topic, duration)
    }
    .preferredColorScheme(.dark)
}

#Preview("New goal") {
    GoalEditorView(requiresConfirmation: false) { topic, duration in
        print("New:", topic, duration)
    }
    .preferredColorScheme(.dark)
}
