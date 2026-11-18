import SwiftUI

// MARK: - Chip

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private var label: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }

    var body: some View {
        if isSelected {
            Button(action: action) { label }
                .buttonStyle(.glassProminent)
                .tint(Color.appOrange)
                .foregroundStyle(.white)
        } else {
            Button(action: action) { label }
                .buttonStyle(.glass)
                .foregroundStyle(Color.primary.opacity(0.35))
        }
    }
}

#Preview {
    HStack {
        DurationChip(title: "Week", isSelected: true) {}
        DurationChip(title: "Month", isSelected: false) {}
    }
    .padding()
}
