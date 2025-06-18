import SwiftUI

@main
struct EmpireApp: App {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var taskStore = TaskStore()
    @StateObject private var incomeStore = IncomeStore()
    @StateObject private var healthStore = HealthStore()
    @StateObject private var statusStore = StatusStore()
    @StateObject private var historyStore = HistoryStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(historyStore)
                .environmentObject(settingsStore)
                .environmentObject(taskStore)
                .environmentObject(incomeStore)
                .environmentObject(healthStore)
                .environmentObject(statusStore)
                .onAppear {
                    // Apply theme on launch
                    UITabBar.updateAppearance(theme: settingsStore.currentTheme)
                }
                .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
                    // Update appearance when theme changes
                    UITabBar.updateAppearance(theme: settingsStore.currentTheme)
                }
        }
    }
}
