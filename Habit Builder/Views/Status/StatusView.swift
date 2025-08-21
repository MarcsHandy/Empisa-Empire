import SwiftUI

struct StatusView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var statusStore = StatusStore()
    @State private var showingPlatformSheet = false
    @State private var newPlatformName = ""
    @State private var newPlatformIcon = "questionmark"
    
    // Simple device detection
    private var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: isiPad ? 24 : 16) {
                        // Today's Summary
                        todaySummarySection
                        
                        // Platform Metrics
                        platformMetricsSection
                        
                        // Add Platform Button
                        if statusStore.platforms.count < 5 {
                            addPlatformButton
                        }
                    }
                    .padding(.vertical, isiPad ? 24 : 16)
                }
                .navigationTitle("Social Status")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
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
        .navigationViewStyle(.stack)
    }
    
    private var todaySummarySection: some View {
        let todayMetrics = statusStore.getTodayMetrics()
        
        return VStack(spacing: isiPad ? 20 : 16) {
            Text("Today's Activity")
                .font(isiPad ? .title2 : .headline)
                .bold()
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, isiPad ? 24 : 16)
            
            // Use LazyVGrid for both devices with different column counts
            let columns = [GridItem](repeating: .init(.flexible(), spacing: isiPad ? 20 : 12),
                                count: isiPad ? 4 : 2)
            
            LazyVGrid(columns: columns, spacing: isiPad ? 20 : 12) {
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
            .padding(.horizontal, isiPad ? 24 : 16)
        }
    }
    
    private var platformMetricsSection: some View {
        VStack(spacing: isiPad ? 20 : 16) {
            Text("Platform Breakdown")
                .font(isiPad ? .title2 : .headline)
                .bold()
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, isiPad ? 24 : 16)
            
            // Simple conditional layout
            if isiPad {
                // iPad layout - 2 columns
                let columns = [GridItem](repeating: .init(.flexible(), spacing: 20), count: 2)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(statusStore.platforms) { platform in
                        PlatformCard(platform: platform, statusStore: statusStore, isiPad: true)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                // iPhone layout - single column
                VStack(spacing: 12) {
                    ForEach(statusStore.platforms) { platform in
                        PlatformCard(platform: platform, statusStore: statusStore, isiPad: false)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var addPlatformButton: some View {
        Button(action: { showingPlatformSheet = true }) {
            HStack {
                Image(systemName: "plus")
                Text("Add Platform")
            }
            .foregroundColor(settings.currentTheme.accentColor)
            .padding()
            .frame(maxWidth: isiPad ? 400 : .infinity)
            .background(settings.currentTheme.backgroundColor.opacity(0.2))
            .cornerRadius(10)
        }
        .padding(.horizontal, isiPad ? 24 : 16)
    }
    
    private var addPlatformSheet: some View {
        NavigationView {
            // Keep your existing sheet content
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
    let isiPad: Bool
    
    var body: some View {
        let todayMetrics = statusStore.getTodayMetrics()
        
        return VStack(spacing: isiPad ? 16 : 12) {
            HStack {
                Image(systemName: platform.icon)
                    .font(isiPad ? .title : .headline)
                    .foregroundColor(settings.currentTheme.accentColor)
                
                Text(platform.name)
                    .font(isiPad ? .headline : .subheadline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
            }
            
            HStack(spacing: isiPad ? 20 : 12) {
                StatusMetricPill(
                    value: "\(todayMetrics.count(for: .post, platformId: platform.id))",
                    label: "Posts",
                    color: .blue,
                    action: { statusStore.incrementMetric(for: platform.id, metric: .post) },
                    isiPad: isiPad
                )
                
                StatusMetricPill(
                    value: "\(todayMetrics.count(for: .comment, platformId: platform.id))",
                    label: "Comments",
                    color: .green,
                    action: { statusStore.incrementMetric(for: platform.id, metric: .comment) },
                    isiPad: isiPad
                )
                
                StatusMetricPill(
                    value: "\(todayMetrics.count(for: .minute, platformId: platform.id))",
                    label: "Minutes",
                    color: .orange,
                    action: { statusStore.incrementMetric(for: platform.id, metric: .minute) },
                    isiPad: isiPad
                )
            }
        }
        .padding(isiPad ? 16 : 12)
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(12)
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
    let isiPad: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(value)
                    .font(isiPad ? .subheadline.bold() : .caption.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                Text(label)
                    .font(isiPad ? .caption : .caption2)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            .padding(isiPad ? 12 : 8)
            .frame(minWidth: isiPad ? 80 : 60)
            .background(color.opacity(0.2))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
