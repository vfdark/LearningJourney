import SwiftUI

/// TASK 3: "New Learning goal". Opens from the "Set a goal" button.
struct GoalEditorView: View {

    @State private var viewModel = GoalEditorViewModel()
    @FocusState private var isTopicFocused: Bool
    @Environment(\.dismiss) private var dismiss

    /// Called with the new topic and duration when the user taps "Start Learning"
    let onSave: (String, LearningDuration) -> Void

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
                .onTapGesture { isTopicFocused = false }

            VStack(alignment: .leading, spacing: 0) {

                // Title and close button
                HStack {
                    Text("Learning Goal")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                }

                // Topic
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
                .padding(.top, 40)
                .contentShape(Rectangle())
                .onTapGesture { isTopicFocused = true }

                // Duration
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

                // Save
                Button {
                    isTopicFocused = false
                    onSave(viewModel.cleanedTopic, viewModel.duration)
                    dismiss()
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
                .disabled(!viewModel.canSave)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
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
    GoalEditorView { topic, duration in
        print("New goal:", topic, duration)
    }
    .preferredColorScheme(.dark)
}
