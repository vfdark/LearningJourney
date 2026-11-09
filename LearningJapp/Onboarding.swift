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
    // #FF9230
    static let appOrange = Color(red: 255 / 255, green: 146 / 255, blue: 48 / 255)
}

// MARK: - Onboarding

struct OnboardingView: View {
    @State private var topic: String = ""
    @State private var duration: LearningDuration = .week
    @FocusState private var isTopicFocused: Bool

    var onStart: (String, LearningDuration) -> Void = { _, _ in }

    var body: some View {
        ZStack {
            // Tap on the background dismisses the keyboard.
            // It must NOT be on the root view, or it swallows the button taps.
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
                    .submitLabel(.done)
                    .onSubmit { isTopicFocused = false }

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

                    HStack(spacing: 12) {
                        ForEach(LearningDuration.allCases) { option in
                            DurationChip(
                                title: option.rawValue,
                                isSelected: duration == option
                            ) {
                                isTopicFocused = false
                                withAnimation(.smooth(duration: 0.25)) {
                                    duration = option
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
                        isTopicFocused = false
                        onStart(topic, duration)
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
    }
}

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isSelected ? .white : Color(hex: "999999"))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        if isSelected {
                            // Selected Orange Glass Fill
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 255/255, green: 160/255, blue: 60/255),
                                            Color(red: 255/255, green: 130/255, blue: 0/255)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            // Top Glass Highlight Rim
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        } else {
                            // Unselected Glass Fill
                            Capsule()
                                .fill(Color(hex: "111111").opacity(0.85))
                            
                            // Thin Glass Border
                            Capsule()
                                .stroke(Color(hex: "262626"), lineWidth: 1)
                        }
                    }
                )
                .shadow(
                    color: isSelected ? Color.appOrange.opacity(0.35) : .clear,
                    radius: 10,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(.plain)
    }
}

// Helper extension for Hex colors from your Sketch inspector
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
#Preview {
    OnboardingView()
}
