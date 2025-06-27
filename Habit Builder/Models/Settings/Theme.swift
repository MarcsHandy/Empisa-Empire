import SwiftUI
import Foundation

// MARK: - Theme System
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light
    case darkGold
    case cyberpunk
    
    var id: String { self.rawValue }
    
    var primaryColor: Color {
        switch self {
        case .light: return .africanSun
        case .darkGold: return .gold
        case .cyberpunk: return .neonPink
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .light: return .africanSoil
        case .darkGold: return .darkGray
        case .cyberpunk: return .neonBlue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .light: return .white
        case .darkGold: return .black
        case .cyberpunk: return .darkPurple
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return .black
        case .darkGold: return .gold
        case .cyberpunk: return .neonGreen
        }
    }
    
    var accentColor: Color {
        switch self {
        case .light: return .kenteRed
        case .darkGold: return .gold
        case .cyberpunk: return .neonPurple
        }
    }
}

enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    var id: Int { self.rawValue }
    
    var shortName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.shortWeekdaySymbols[rawValue - 1]
    }
}

// MARK: - Color Extensions
extension Color {
    // African Theme Colors
    static let africanSun = Color(red: 0.85, green: 0.55, blue: 0.13)
    static let africanSoil = Color(red: 0.45, green: 0.25, blue: 0.15)
    static let africanSky = Color(red: 0.20, green: 0.40, blue: 0.60)
    static let africanLeaf = Color(red: 0.20, green: 0.50, blue: 0.20)
    static let africanClay = Color(red: 0.75, green: 0.35, blue: 0.25)
    static let kenteYellow = Color(red: 1.00, green: 0.80, blue: 0.00)
    static let kenteRed = Color(red: 0.75, green: 0.15, blue: 0.15)
    static let kenteGreen = Color(red: 0.00, green: 0.50, blue: 0.25)
    static let adinkraOrange = Color(red: 0.90, green: 0.40, blue: 0.10)
    
    // Dark Gold Theme Colors
    static let gold = Color(red: 0.83, green: 0.69, blue: 0.22)
    static let darkGray = Color(red: 0.1, green: 0.1, blue: 0.1)
    
    // Cyberpunk Theme Colors
    static let neonPink = Color(red: 1.00, green: 0.07, blue: 0.57)
    static let neonBlue = Color(red: 0.30, green: 0.85, blue: 1.00)
    static let neonGreen = Color(red: 0.30, green: 1.00, blue: 0.50)
    static let neonPurple = Color(red: 0.70, green: 0.30, blue: 1.00)
    static let darkPurple = Color(red: 0.15, green: 0.05, blue: 0.30)
}
