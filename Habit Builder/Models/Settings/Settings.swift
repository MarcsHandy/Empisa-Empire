import SwiftUI
import AVFoundation
import Foundation

class SettingsStore: ObservableObject {
    @Published var currentTheme: AppTheme = .light {
        didSet {
            saveSettings()
            UITabBar.updateAppearance(theme: currentTheme)
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    @Published var waterUnit: WaterUnit {
        didSet {
            UserDefaults.standard.set(waterUnit.rawValue, forKey: "waterUnitPreference")
        }
    }
    enum WaterUnit: String, CaseIterable {
        case liters = "L"
        case ounces = "oz"
        
        var conversionFactor: Double {
            switch self {
            case .liters: return 1.0
            case .ounces: return 33.814
            }
        }
    }
    
    init() {
        // First load the water unit preference
        let savedUnit = UserDefaults.standard.string(forKey: "waterUnitPreference")
        self.waterUnit = WaterUnit(rawValue: savedUnit ?? "L") ?? .liters
        
        // Then load other settings
        loadSettings()
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(encoded, forKey: "appTheme")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "appTheme"),
           let decoded = try? JSONDecoder().decode(AppTheme.self, from: data) {
            currentTheme = decoded
        }
    }
}
