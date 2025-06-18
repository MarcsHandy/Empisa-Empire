import Foundation

enum GoalType: String, CaseIterable, Codable {
    case daily = "Daily"
    case monthly = "30 Days"
    case quarterly = "120 Days"
}
