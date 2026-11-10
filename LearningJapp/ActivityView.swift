import SwiftUI

// STEP 1: the screen background and the header (title, date, two round buttons).
// Everything here is fake and fixed for now. No logic yet.

struct ActivityView: View {

    var body: some View {
        ZStack {
            // 1. Background fills the whole screen
            Color.stepBackground
                .ignoresSafeArea()

            // 2. Everything else is stacked vertically on top of it
            VStack(alignment: .leading, spacing: 0) {
                header
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {

            // Left side: title and date
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))

                Text("Thursday, 24 October")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right side: two round glass buttons
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
}

// MARK: - Background color (light: system white, dark: #111111)

private extension Color {
    static let stepBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
            : .systemBackground
    })
}

#Preview {
    ActivityView()
        .preferredColorScheme(.dark)
}
