import SwiftUI
import AVFoundation
import Foundation

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var showingThemeEditor = false
    @State private var showingNotificationSettings = false
    @State private var showingDataOptions = false
    
    var body: some View {
        NavigationView {
            List {
                // Appearance Section
                Section(header: Text("Appearance").foregroundColor(settings.currentTheme.textColor)) {
                    NavigationLink(destination: ThemeEditorView()) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Theme Settings")
                            Spacer()
                            Circle()
                                .fill(settings.currentTheme.accentColor)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    Picker("Water Unit", selection: $settings.waterUnit) {
                        ForEach(SettingsStore.WaterUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.2))
                
                // Notifications Section
                Section(header: Text("Notifications").foregroundColor(settings.currentTheme.textColor)) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Notification Preferences")
                        }
                    }
                    
                    Toggle(isOn: $settings.dailyReminders) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Daily Reminders")
                        }
                    }
                }
                .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.2))
                
                // Data Section
                Section(header: Text("Data").foregroundColor(settings.currentTheme.textColor)) {
                    NavigationLink(destination: DataManagementView()) {
                        HStack {
                            Image(systemName: "externaldrive")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Data Management")
                        }
                    }
                    
                    Button {
                        settings.exportAllData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Export All Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingDataOptions = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Reset All Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.2))
                
                // About Section
                Section(header: Text("About").foregroundColor(settings.currentTheme.textColor)) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(settings.currentTheme.accentColor)
                        Text("Version")
                        Spacer()
                        Text("1.2.0")
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    }
                    
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(settings.currentTheme.accentColor)
                        Text("Build Number")
                        Spacer()
                        Text("210")
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    }
                    
                    Link(destination: URL(string: "https://yourapp.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://yourapp.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(settings.currentTheme.accentColor)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.2))
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset All Data", isPresented: $showingDataOptions, titleVisibility: .visible) {
                Button("Reset Settings Only", role: .destructive) {
                    settings.resetSettings()
                }
                Button("Reset All Data", role: .destructive) {
                    settings.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
}

// Theme Editor View
struct ThemeEditorView: View {
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        Form {
            Section(header: Text("Select Theme").foregroundColor(settings.currentTheme.textColor)) {
                Picker("App Theme", selection: $settings.currentTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue.capitalized).tag(theme)
                    }
                }
                .pickerStyle(.inline)
            }
            
            Section(header: Text("Preview").foregroundColor(settings.currentTheme.textColor)) {
                VStack(spacing: 20) {
                    Text("Sample Text")
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Button("Sample Button") {}
                        .buttonStyle(.borderedProminent)
                        .tint(settings.currentTheme.accentColor)
                    
                    HStack {
                        Circle()
                            .fill(settings.currentTheme.primaryColor)
                            .frame(width: 30, height: 30)
                        Circle()
                            .fill(settings.currentTheme.secondaryColor)
                            .frame(width: 30, height: 30)
                        Circle()
                            .fill(settings.currentTheme.backgroundColor)
                            .frame(width: 30, height: 30)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(settings.currentTheme.backgroundColor.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .navigationTitle("Theme Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Notification Settings View
struct NotificationSettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        Form {
            Section(header: Text("General").foregroundColor(settings.currentTheme.textColor)) {
                Toggle(isOn: $settings.notificationsEnabled) {
                    Text("Enable Notifications")
                }
                
                if settings.notificationsEnabled {
                    DatePicker("Daily Reminder Time",
                               selection: $settings.dailyReminderTime,
                               displayedComponents: .hourAndMinute)
                }
            }
            
            Section(header: Text("Notification Types").foregroundColor(settings.currentTheme.textColor)) {
                Toggle(isOn: $settings.taskReminders) {
                    Text("Task Reminders")
                }
                
                Toggle(isOn: $settings.goalReminders) {
                    Text("Goal Reminders")
                }
                
                Toggle(isOn: $settings.healthReminders) {
                    Text("Health Reminders")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Data Management View
struct DataManagementView: View {
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        Form {
            Section(header: Text("Backup").foregroundColor(settings.currentTheme.textColor)) {
                Button {
                    settings.exportAllData()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(settings.currentTheme.accentColor)
                        Text("Export All Data")
                    }
                }
                
                Button {
                    settings.importData()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(settings.currentTheme.accentColor)
                        Text("Import Data")
                    }
                }
            }
            
            Section(header: Text("Advanced").foregroundColor(settings.currentTheme.textColor)) {
                NavigationLink(destination: DataResetView()) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Reset Options")
                    }
                }
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Data Reset View
struct DataResetView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var showingResetConfirmation = false
    
    var body: some View {
        Form {
            Section {
                Button(role: .destructive) {
                    showingResetConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Reset All Data")
                    }
                }
            }
        }
        .navigationTitle("Reset Options")
        .confirmationDialog("Reset All Data", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset Settings Only", role: .destructive) {
                settings.resetSettings()
            }
            Button("Reset All Data", role: .destructive) {
                settings.resetAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone. All your data will be permanently deleted.")
        }
    }
}
