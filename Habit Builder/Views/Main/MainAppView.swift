import SwiftUI
import AVFoundation
import Foundation
import FirebaseAuth

struct MainAppView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var taskStore = TaskStore()
    @StateObject private var incomeStore = IncomeStore()
    @StateObject private var expenseStore = ExpenseStore()
    @StateObject private var healthStore = HealthStore()
    @StateObject private var statusStore = StatusStore()
    
    @State private var selectedTab: ContentView.Tab = .income
    @State private var isMenuOpen = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                Group {
                    switch selectedTab {
                    case .tasks:
                        TaskView(taskStore: taskStore)
                    case .income:
                        IncomeView(incomeStore: incomeStore, expenseStore: expenseStore)
                    case .health:
                        HealthView(healthStore: healthStore)
                    case .status:
                        StatusView()
                    case .revision:
                        RevisionView()
                    case .goals:
                        GoalsView()
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsView(authViewModel: authViewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: isMenuOpen ? UIScreen.main.bounds.width * 0.6 : 0)
                .disabled(isMenuOpen)
                
                // Side menu with tap to dismiss overlay
                if isMenuOpen {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                    
                    SideMenuView(
                        selectedTab: $selectedTab,
                        isMenuOpen: $isMenuOpen,
                        authViewModel: authViewModel
                    )
                    .transition(.move(edge: .leading))
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                if gesture.translation.width < -100 {
                                    withAnimation {
                                        isMenuOpen = false
                                    }
                                }
                            }
                    )
                }
            }
            .navigationBarTitle(selectedTab.title, displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .imageScale(.large)
                    .foregroundColor(settingsStore.currentTheme.accentColor)
            })
            .environmentObject(settingsStore)
            .onAppear {
                setupAppearance(theme: settingsStore.currentTheme)
            }
            .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
                setupAppearance(theme: settingsStore.currentTheme)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func setupAppearance(theme: AppTheme) {
        UINavigationBar.appearance().backgroundColor = UIColor(theme.backgroundColor)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(theme.textColor)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(theme.textColor)]
        UINavigationBar.appearance().tintColor = UIColor(theme.accentColor)
    }
}
