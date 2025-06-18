import SwiftUI
import AVFoundation
import Foundation

extension SettingsStore {
    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "notificationsEnabled") }
    }
    
    var dailyReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "dailyReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "dailyReminders") }
    }
    
    var dailyReminderTime: Date {
        get {
            UserDefaults.standard.object(forKey: "dailyReminderTime") as? Date ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
        set { UserDefaults.standard.set(newValue, forKey: "dailyReminderTime") }
    }
    
    var taskReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "taskReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "taskReminders") }
    }
    
    var goalReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "goalReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "goalReminders") }
    }
    
    var healthReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "healthReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "healthReminders") }
    }
    
    func exportAllData() {
        // Implementation for exporting data
        print("Exporting all data...")
    }
    
    func importData() {
        // Implementation for importing data
        print("Importing data...")
    }
    
    func resetSettings() {
        UserDefaults.standard.removeObject(forKey: "appTheme")
        UserDefaults.standard.removeObject(forKey: "waterUnitPreference")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "dailyReminders")
        UserDefaults.standard.removeObject(forKey: "dailyReminderTime")
        UserDefaults.standard.removeObject(forKey: "taskReminders")
        UserDefaults.standard.removeObject(forKey: "goalReminders")
        UserDefaults.standard.removeObject(forKey: "healthReminders")
        
        // Reset to default values
        currentTheme = .light
        waterUnit = .liters
    }
    
    func resetAllData() {
        resetSettings()
        // Add additional data clearing here
        UserDefaults.standard.removeObject(forKey: "tasks")
        UserDefaults.standard.removeObject(forKey: "goals")
        UserDefaults.standard.removeObject(forKey: "healthRecords")
        UserDefaults.standard.removeObject(forKey: "incomeRecords")
        UserDefaults.standard.removeObject(forKey: "expenses")
    }
}


extension Calendar {
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]
        enumerateDates(startingAfter: dateInterval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date, date < dateInterval.end else {
                stop = true
                return
            }
            dates.append(date)
        }
        return dates
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

extension UITabBar {
    static func updateAppearance(theme: AppTheme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(theme.backgroundColor)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(theme.textColor.opacity(0.6))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(theme.textColor.opacity(0.6))
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(theme.accentColor)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(theme.accentColor)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension DateFormatter {
    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    static var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
}

extension View {
    func healthMetricCardEditModifier(
        isPresented: Binding<Bool>,
        title: String,
        value: Binding<String>,
        healthStore: HealthStore,
        date: Date = Date()
    ) -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented.wrappedValue = true
            }
            .sheet(isPresented: isPresented) {
                EditSingleHealthView(
                    healthStore: healthStore,
                    title: title,
                    value: value,
                    date: date
                )
            }
    }
}

extension Double {
    func converted(to unit: SettingsStore.WaterUnit) -> Double {
        switch unit {
        case .liters: return self
        case .ounces: return self * 33.814
        }
    }
}

extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: self.startOfWeek) ?? self
    }
}
