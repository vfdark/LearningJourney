import Foundation

/// How long the goal lasts. Week, Month or Year.
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

    /// Days needed to complete the goal: 7, 30 or 365
    var targetDays: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }
}
