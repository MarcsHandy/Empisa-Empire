import SwiftUI
import AVFoundation
import Foundation

struct ContentView: View {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        // Use ZStack instead of Group for better type inference
        ZStack {
            if authViewModel.isAuthenticated {
                MainAppView(authViewModel: authViewModel)
                    .environmentObject(settingsStore)
            } else {
                LoginView(authViewModel: authViewModel)
                    .environmentObject(settingsStore)
            }
        }
        .onAppear {
            print("📱 App appeared - Authenticated: \(authViewModel.isAuthenticated)")
        }
    }
}

// Keep your Tab enum outside the view
extension ContentView {
    enum Tab: String, CaseIterable, Identifiable {
        case tasks
        case income
        case health
        case status
        case revision
        case goals
        case history
        case settings
        
        var id: String { self.rawValue }
        
        var title: String {
            switch self {
            case .tasks: return "Tasks"
            case .income: return "Income"
            case .health: return "Health"
            case .status: return "Status"
            case .revision: return "Daily Revision"
            case .goals: return "My Goals"
            case .history: return "History"
            case .settings: return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .tasks: return "calendar"
            case .income: return "dollarsign.circle"
            case .health: return "heart.fill"
            case .status: return "chart.line.uptrend.xyaxis"
            case .revision: return "arrow.clockwise"
            case .goals: return "target"
            case .history: return "book.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
}
