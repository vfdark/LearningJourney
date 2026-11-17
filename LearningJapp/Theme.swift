import SwiftUI
import UIKit

extension Color {
    /// Screen background. Light mode = system white, dark mode = #111111.
    static let appBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
            : .systemBackground
    })

    /// Brand orange #FF9230
    static let appOrange = Color(red: 255 / 255, green: 146 / 255, blue: 48 / 255)

    /// Freeze cyan #6DD0F9 (the design's "7 Cyan"): snowflake, freezed days, Freeze button
    static let appBlue = Color(red: 109 / 255, green: 208 / 255, blue: 249 / 255)
}
