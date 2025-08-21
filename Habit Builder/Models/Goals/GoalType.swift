import Foundation

enum GoalType: String, CaseIterable, Codable {
    case daily = "Daily"
    case monthly = "30 Days"
    case quarterly = "120 Days"
    
    var iconName: String {
        switch self {
        case .daily: return "calendar.day.timeline.left"
        case .monthly: return "calendar"
        case .quarterly: return "calendar.badge.clock"
        }
    }
    
    var durationInDays: Int {
        switch self {
        case .daily: return 1
        case .monthly: return 30
        case .quarterly: return 120
        }
    }
    
    // For accessibility labels
    var accessibilityLabel: String {
        switch self {
        case .daily: return "Daily goals"
        case .monthly: return "30 day goals"
        case .quarterly: return "120 day goals"
        }
    }
}
