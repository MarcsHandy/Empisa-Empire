import SwiftUI
import AVFoundation
import Foundation

struct SideMenuView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedTab: ContentView.Tab
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        ZStack {
            settings.currentTheme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // App title/header
                    VStack(alignment: .leading) {
                        Text("Empisa Empire")
                            .font(.title)
                            .bold()
                            .foregroundColor(settings.currentTheme.textColor)
                        Text("Track your progress")
                            .font(.subheadline)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 20)
                    
                    // Past / History / Body Section
                    SectionHeader(title: "Past / History / Body")
                    
                    // History button moved here under Past section
                    MenuItemButton(tab: .history, selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    
                    Divider()
                        .background(settings.currentTheme.textColor.opacity(0.2))
                        .padding(.vertical, 8)
                    
                    // Present / Philosophy / Mind Section
                    SectionHeader(title: "Present / Philosophy / Mind")
                    
                    // Removed History from this section
                    ForEach(ContentView.Tab.allCases.filter { tab in
                        tab != .settings && tab != .goals && tab != .history
                    }) { tab in
                        MenuItemButton(tab: tab, selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    }
                    
                    // Goals (special case)
                    MenuItemButton(tab: .goals, selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    
                    Divider()
                        .background(settings.currentTheme.textColor.opacity(0.2))
                        .padding(.vertical, 8)
                    
                    // Future / Ethics / Spirit Section
                    SectionHeader(title: "Future / Ethics / Spirit")
                    
                    Text("Ethics Coming Soon")
                        .font(.subheadline)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Settings at the bottom
                    MenuItemButton(tab: .settings, selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                        .padding(.bottom, 30)
                }
                .padding(.leading, 20)
                .frame(width: UIScreen.main.bounds.width * 0.7)
            }
            .background(settings.currentTheme.backgroundColor)
        }
    }
}

struct SectionHeader: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
}

struct MenuItemButton: View {
    @EnvironmentObject var settings: SettingsStore
    let tab: ContentView.Tab
    @Binding var selectedTab: ContentView.Tab
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        Button(action: {
            selectedTab = tab
            withAnimation {
                isMenuOpen = false
            }
        }) {
            HStack {
                Image(systemName: tab.icon)
                    .foregroundColor(selectedTab == tab ? settings.currentTheme.accentColor : settings.currentTheme.textColor)
                    .frame(width: 30)
                Text(tab.title)
                    .foregroundColor(selectedTab == tab ? settings.currentTheme.accentColor : settings.currentTheme.textColor)
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(selectedTab == tab ? settings.currentTheme.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(10)
        }
    }
}

// Reusable Menu Button View
struct MenuButton: View {
    @EnvironmentObject var settings: SettingsStore
    let tab: ContentView.Tab
    @Binding var selectedTab: ContentView.Tab
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        Button(action: {
            selectedTab = tab
            withAnimation {
                isMenuOpen = false
            }
        }) {
            HStack {
                Image(systemName: tab.icon)
                    .foregroundColor(selectedTab == tab ? settings.currentTheme.accentColor : settings.currentTheme.textColor)
                    .frame(width: 30)
                Text(tab.title)
                    .foregroundColor(selectedTab == tab ? settings.currentTheme.accentColor : settings.currentTheme.textColor)
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(selectedTab == tab ? settings.currentTheme.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(10)
        }
    }
}
