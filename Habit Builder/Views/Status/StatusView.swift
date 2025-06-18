import SwiftUI
import AVFoundation
import Foundation

struct StatusView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var statusStore = StatusStore()
    @State private var showingPlatformSheet = false
    @State private var newPlatformName = ""
    @State private var newPlatformIcon = "questionmark"
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Summary
                        todaySummarySection
                        
                        // Platform Metrics
                        platformMetricsSection
                        
                        // Add Platform Button
                        if statusStore.platforms.count < 5 {
                            Button(action: { showingPlatformSheet = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Platform")
                                }
                                .foregroundColor(settings.currentTheme.accentColor)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(settings.currentTheme.backgroundColor.opacity(0.2))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Social Status")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Refresh action if needed
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingPlatformSheet) {
                    addPlatformSheet
                }
            }
        }
    }
    
    private var todaySummarySection: some View {
        let todayMetrics = statusStore.getTodayMetrics()
        
        return VStack(spacing: 16) {
            Text("Today's Activity")
                .font(.title2.bold())
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatusMetricCard(
                    title: "Posts",
                    value: todayMetrics.posts.values.reduce(0, +),
                    icon: "square.and.pencil",
                    color: .blue
                )
                
                StatusMetricCard(
                    title: "Comments",
                    value: todayMetrics.comments.values.reduce(0, +),
                    icon: "text.bubble",
                    color: .green
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatusMetricCard(
                    title: "Minutes",
                    value: todayMetrics.minutes.values.reduce(0, +),
                    icon: "clock",
                    color: .orange
                )
                
                StatusMetricCard(
                    title: "Platforms",
                    value: statusStore.platforms.count,
                    icon: "apps.iphone",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var platformMetricsSection: some View {
        VStack(spacing: 16) {
            Text("Platform Breakdown")
                .font(.title2.bold())
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ForEach(statusStore.platforms) { platform in
                PlatformCard(platform: platform, statusStore: statusStore)
                    .padding(.horizontal)
            }
        }
    }
    
    private var addPlatformSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Platform Details").foregroundColor(settings.currentTheme.accentColor)) {
                    TextField("Platform Name", text: $newPlatformName)
                    
                    Picker("Icon", selection: $newPlatformIcon) {
                        Image(systemName: "camera").tag("camera")
                        Image(systemName: "bird").tag("bird")
                        Image(systemName: "music.note").tag("music.note")
                        Image(systemName: "play.rectangle").tag("play.rectangle")
                        Image(systemName: "briefcase").tag("briefcase")
                        Image(systemName: "questionmark").tag("questionmark")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Add Platform") {
                        statusStore.addPlatform(name: newPlatformName, icon: newPlatformIcon)
                        showingPlatformSheet = false
                        newPlatformName = ""
                        newPlatformIcon = "questionmark"
                    }
                    .disabled(newPlatformName.isEmpty)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Add Platform")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingPlatformSheet = false
                    }
                }
            }
        }
    }
}

struct PlatformCard: View {
    @EnvironmentObject var settings: SettingsStore
    let platform: Platform
    @ObservedObject var statusStore: StatusStore
    
    var body: some View {
        let todayMetrics = statusStore.getTodayMetrics()
        
        return VStack(spacing: 12) {
            HStack {
                Image(systemName: platform.icon)
                    .font(.title)
                    .foregroundColor(settings.currentTheme.accentColor)
                
                Text(platform.name)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatusMetricPill(
                    value: "\(todayMetrics.count(for: .post, platformId: platform.id))",
                    label: "Posts",
                    color: .blue,
                    action: {
                        statusStore.incrementMetric(for: platform.id, metric: .post)
                    }
                )
                
                StatusMetricPill(
                    value: "\(todayMetrics.count(for: .comment, platformId: platform.id))",
                    label: "Comments",
                    color: .green,
                    action: {
                        statusStore.incrementMetric(for: platform.id, metric: .comment)
                    }
                )
                
                StatusMetricPill(
                    value: "\(todayMetrics.count(for: .minute, platformId: platform.id))",
                    label: "Minutes",
                    color: .orange,
                    action: {
                        statusStore.incrementMetric(for: platform.id, metric: .minute)
                    }
                )
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(10)
    }
}

struct StatusMetricCard: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Text("\(value)")
                    .font(.title2.bold())
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(10)
    }
}

struct StatusMetricPill: View {
    @EnvironmentObject var settings: SettingsStore
    let value: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            .padding(8)
            .frame(minWidth: 60)
            .background(color.opacity(0.2))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
