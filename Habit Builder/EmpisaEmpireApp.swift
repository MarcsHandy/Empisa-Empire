import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct EmpireApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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
