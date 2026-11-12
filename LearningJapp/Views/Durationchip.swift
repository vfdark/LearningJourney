import SwiftUI

/// The Week / Month / Year chip. Used by Onboarding and the Learning Goal screen.
struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        // One single button (same identity selected or not): only the tint and text color change.
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
