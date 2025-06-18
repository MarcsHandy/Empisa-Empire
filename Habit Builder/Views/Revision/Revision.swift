import SwiftUI
import AVFoundation
import Foundation

struct RevisionView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var revisionStore = RevisionStore()
    @State private var showingAddRevision = false
    @State private var showingWeeklyRetrospective = false
    @State private var selectedWeek: Date = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Summary Card
                    todaysSummaryCard
                    
                    // Weekly Retrospective Section
                    weeklyRetrospectiveSection
                    
                    // Recent Revisions
                    recentRevisionsSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Daily Revision")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRevision = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddRevision) {
                AddRevisionView(revisionStore: revisionStore)
            }
            .sheet(isPresented: $showingWeeklyRetrospective) {
                WeeklyRetrospectiveView(
                    retrospective: getCurrentWeeklyRetrospective(),
                    revisionStore: revisionStore
                )
            }
        }
    }
    
    private var todaysSummaryCard: some View {
        let todaysRevision = revisionStore.getTodaysRevision()
        let moodColor = moodToColor(todaysRevision.mood)
        
        return VStack(spacing: 16) {
            HStack {
                Text("Today's Review")
                    .font(.title2.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                // Mood indicator
                Text(todaysRevision.mood.rawValue)
                    .font(.title)
                    .padding(8)
                    .background(moodColor.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.horizontal)
            
            // Energy level
            HStack {
                Text("Energy:")
                    .foregroundColor(settings.currentTheme.textColor)
                
                ForEach(1...5, id: \.self) { level in
                    Image(systemName: level <= todaysRevision.energyLevel ? "bolt.fill" : "bolt")
                        .foregroundColor(level <= todaysRevision.energyLevel ? .yellow : settings.currentTheme.textColor.opacity(0.3))
                }
            }
            
            // Key metrics
            HStack(spacing: 16) {
                RevisionMetricPill(value: "\(todaysRevision.keyAchievements.count)", label: "Wins", color: .green)
                RevisionMetricPill(value: "\(todaysRevision.gratitudeList.count)", label: "Gratitude", color: .blue)
            }
            
            Button(action: { showingAddRevision = true }) {
                Text(todaysRevision.whatWentWell.isEmpty ? "Start Today's Review" : "Edit Today's Review")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settings.currentTheme.accentColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var weeklyRetrospectiveSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Retrospective")
                    .font(.title2.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                if getCurrentWeeklyRetrospective() != nil {
                    Button(action: { showingWeeklyRetrospective = true }) {
                        Text("View")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            
            if let currentRetro = getCurrentWeeklyRetrospective() {
                WeeklyRetrospectiveCard(retrospective: currentRetro)
                    .onTapGesture { showingWeeklyRetrospective = true }
                    .padding(.horizontal)
            } else {
                Text("Your weekly retrospective will be available at the end of the week")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settings.currentTheme.backgroundColor.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
    
    private var recentRevisionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Days")
                    .font(.title2.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(revisionStore.dailyRevisions.sorted(by: { $0.date > $1.date }).prefix(3)) { revision in
                DailyRevisionCard(revision: revision)
                    .padding(.horizontal)
            }
        }
    }
    
    private func getCurrentWeeklyRetrospective() -> RevisionStore.WeeklyRetrospective? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return revisionStore.weeklyRetrospectives.first { retrospective in
            calendar.isDate(today, equalTo: retrospective.endDate, toGranularity: .day)
        }
    }
    
    private func moodToColor(_ mood: RevisionStore.DailyRevision.Mood) -> Color {
        switch mood {
        case .terrible: return .red
        case .bad: return .orange
        case .neutral: return .gray
        case .good: return .green
        case .great: return .blue
        }
    }
}

struct DailyRevisionCard: View {
    @EnvironmentObject var settings: SettingsStore
    let revision: RevisionStore.DailyRevision
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(revision.date, format: .dateTime.day().month())
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                Text(revision.mood.rawValue)
                    .font(.title3)
            }
            
            if !revision.whatWentWell.isEmpty {
                Text(revision.whatWentWell)
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor)
                    .lineLimit(2)
            }
            
            if !revision.keyAchievements.isEmpty {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(revision.keyAchievements.count) achievements")
                        .font(.caption)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(10)
    }
}

struct WeeklyRetrospectiveCard: View {
    @EnvironmentObject var settings: SettingsStore
    let retrospective: RevisionStore.WeeklyRetrospective
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Week of \(retrospective.startDate, format: .dateTime.day().month())")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                // Rating stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= retrospective.rating / 2 ? "star.fill" : "star")
                            .foregroundColor(star <= retrospective.rating / 2 ? .yellow : .gray)
                            .font(.caption)
                    }
                }
            }
            
            if !retrospective.weeklyWins.isEmpty {
                Text("\(retrospective.weeklyWins.count) wins recorded")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.8))
            }
            
            if !retrospective.keyLearnings.isEmpty {
                Text("\(retrospective.keyLearnings.count) key learnings")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.8))
            }
            
            Text("Tap to view full retrospective")
                .font(.caption)
                .foregroundColor(settings.currentTheme.accentColor)
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(10)
    }
}

struct AddRevisionView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var revisionStore: RevisionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var whatWentWell = ""
    @State private var whatToImprove = ""
    @State private var lessonsLearned = ""
    @State private var tomorrowFocus = ""
    @State private var energyLevel: Int = 3
    @State private var mood: RevisionStore.DailyRevision.Mood = .neutral
    @State private var keyAchievements: [String] = []
    @State private var newAchievement = ""
    @State private var gratitudeList: [String] = []
    @State private var newGratitudeItem = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mood and Energy Section
                    moodAndEnergySection
                    
                    // Core Reflection Sections
                    reflectionSection(title: "What Went Well", text: $whatWentWell, icon: "hand.thumbsup.fill", color: .green)
                    reflectionSection(title: "What To Improve", text: $whatToImprove, icon: "exclamationmark.triangle.fill", color: .orange)
                    reflectionSection(title: "Lessons Learned", text: $lessonsLearned, icon: "lightbulb.fill", color: .yellow)
                    reflectionSection(title: "Tomorrow's Focus", text: $tomorrowFocus, icon: "target", color: .blue)
                    
                    // Achievements Section
                    achievementsSection
                    
                    // Gratitude Section
                    gratitudeSection
                    
                    // Save Button
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Daily Revision")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(settings.currentTheme.accentColor)
                }
            }
            .onAppear {
                let todaysRevision = revisionStore.getTodaysRevision()
                whatWentWell = todaysRevision.whatWentWell
                whatToImprove = todaysRevision.whatToImprove
                lessonsLearned = todaysRevision.lessonsLearned
                tomorrowFocus = todaysRevision.tomorrowFocus
                energyLevel = todaysRevision.energyLevel
                mood = todaysRevision.mood
                keyAchievements = todaysRevision.keyAchievements
                gratitudeList = todaysRevision.gratitudeList
            }
        }
    }
    
    private var moodAndEnergySection: some View {
        VStack(spacing: 16) {
            Text("How was your day?")
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Mood Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Mood:")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.8))
                
                HStack {
                    ForEach(RevisionStore.DailyRevision.Mood.allCases, id: \.self) { moodOption in
                        Button(action: { mood = moodOption }) {
                            Text(moodOption.rawValue)
                                .font(.title)
                                .padding(8)
                                .background(mood == moodOption ? moodToColor(moodOption).opacity(0.3) : Color.clear)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Energy Level
            VStack(alignment: .leading, spacing: 8) {
                Text("Energy Level:")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.8))
                
                HStack {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: { energyLevel = level }) {
                            Image(systemName: "bolt\(level <= energyLevel ? ".fill" : "")")
                                .foregroundColor(level <= energyLevel ? .yellow : settings.currentTheme.textColor.opacity(0.3))
                                .padding(8)
                                .background(level <= energyLevel ? Color.yellow.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func reflectionSection(title: String, text: Binding<String>, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            TextEditor(text: text)
                .frame(minHeight: 100)
                .padding(8)
                .background(settings.currentTheme.backgroundColor.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Key Achievements")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            ForEach(keyAchievements, id: \.self) { achievement in
                HStack {
                    Text("• \(achievement)")
                        .font(.subheadline)
                        .foregroundColor(settings.currentTheme.textColor)
                    Spacer()
                    Button(action: {
                        if let index = keyAchievements.firstIndex(of: achievement) {
                            keyAchievements.remove(at: index)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(8)
                .background(settings.currentTheme.backgroundColor.opacity(0.1))
                .cornerRadius(5)
            }
            
            HStack {
                TextField("Add an achievement", text: $newAchievement)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !newAchievement.isEmpty {
                        keyAchievements.append(newAchievement)
                        newAchievement = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    private var gratitudeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Gratitude List")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            ForEach(gratitudeList, id: \.self) { item in
                HStack {
                    Text("• \(item)")
                        .font(.subheadline)
                        .foregroundColor(settings.currentTheme.textColor)
                    Spacer()
                    Button(action: {
                        if let index = gratitudeList.firstIndex(of: item) {
                            gratitudeList.remove(at: index)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(8)
                .background(settings.currentTheme.backgroundColor.opacity(0.1))
                .cornerRadius(5)
            }
            
            HStack {
                TextField("I'm grateful for...", text: $newGratitudeItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !newGratitudeItem.isEmpty {
                        gratitudeList.append(newGratitudeItem)
                        newGratitudeItem = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: saveChanges) {
            Text("Save Daily Revision")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: [
                        settings.currentTheme.accentColor,
                        settings.currentTheme.primaryColor
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .cornerRadius(10)
        }
    }
    
    private func moodToColor(_ mood: RevisionStore.DailyRevision.Mood) -> Color {
        switch mood {
        case .terrible: return .red
        case .bad: return .orange
        case .neutral: return .gray
        case .good: return .green
        case .great: return .blue
        }
    }
    
    private func saveChanges() {
        let revision = RevisionStore.DailyRevision(
            whatWentWell: whatWentWell,
            whatToImprove: whatToImprove,
            lessonsLearned: lessonsLearned,
            tomorrowFocus: tomorrowFocus,
            energyLevel: energyLevel,
            mood: mood,
            keyAchievements: keyAchievements,
            gratitudeList: gratitudeList
        )
        
        revisionStore.addRevision(revision)
        presentationMode.wrappedValue.dismiss()
    }
}

struct WeeklyRetrospectiveView: View {
    @EnvironmentObject var settings: SettingsStore
    let retrospective: RevisionStore.WeeklyRetrospective?
    @ObservedObject var revisionStore: RevisionStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let retrospective = retrospective {
                    VStack(spacing: 20) {
                        // Header with week info
                        VStack {
                            Text("Weekly Retrospective")
                                .font(.title.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                            
                            Text("\(retrospective.startDate, format: .dateTime.day().month()) - \(retrospective.endDate, format: .dateTime.day().month())")
                                .font(.subheadline)
                                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                            
                            // Rating
                            HStack {
                                Text("Week Rating:")
                                    .font(.headline)
                                    .foregroundColor(settings.currentTheme.textColor)
                                
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= retrospective.rating / 2 ? "star.fill" : "star")
                                        .foregroundColor(star <= retrospective.rating / 2 ? .yellow : .gray)
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        // Weekly Wins
                        retrospectiveSection(
                            title: "Weekly Wins",
                            icon: "trophy.fill",
                            color: .green,
                            items: retrospective.weeklyWins
                        )
                        
                        // Challenges
                        retrospectiveSection(
                            title: "Biggest Challenges",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange,
                            items: retrospective.biggestChallenges
                        )
                        
                        // Learnings
                        retrospectiveSection(
                            title: "Key Learnings",
                            icon: "lightbulb.fill",
                            color: .yellow,
                            items: retrospective.keyLearnings
                        )
                        
                        // Improvement Plan
                        retrospectiveSection(
                            title: "Improvement Plan",
                            icon: "arrow.up.forward",
                            color: .blue,
                            items: retrospective.improvementPlan
                        )
                        
                        // Mood Chart
                        moodChartSection
                    }
                    .padding()
                } else {
                    Text("No retrospective available for this week")
                        .foregroundColor(settings.currentTheme.textColor)
                        .padding()
                }
            }
            .navigationTitle("Weekly Review")
        }
    }
    
    private func retrospectiveSection(title: String, icon: String, color: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text("\(items.count)")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            if items.isEmpty {
                Text("No \(title.lowercased()) recorded")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(settings.currentTheme.backgroundColor.opacity(0.1))
                    .cornerRadius(8)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text("• \(item)")
                            .font(.subheadline)
                            .foregroundColor(settings.currentTheme.textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(settings.currentTheme.backgroundColor.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    private var moodChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "face.smiling.fill")
                    .foregroundColor(.pink)
                Text("Mood Throughout the Week")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            // Get the daily revisions for this week
            let weekRevisions = revisionStore.getRevisionsForWeek(containing: retrospective?.endDate ?? Date())
            
            if weekRevisions.isEmpty {
                Text("No daily data available")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(settings.currentTheme.backgroundColor.opacity(0.1))
                    .cornerRadius(8)
            } else {
                MoodChart(revisions: weekRevisions)
                    .frame(height: 200)
                    .padding()
                    .background(settings.currentTheme.backgroundColor.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

struct MoodChart: View {
    @EnvironmentObject var settings: SettingsStore
    let revisions: [RevisionStore.DailyRevision]
    
    private var maxMoodValue: Int {
        RevisionStore.DailyRevision.Mood.allCases.count - 1
    }
    
    private var moodData: [(day: String, mood: Int)] {
        revisions.map { revision in
            let day = revision.date.formatted(.dateTime.weekday(.abbreviated))
            let moodValue = RevisionStore.DailyRevision.Mood.allCases.firstIndex(of: revision.mood) ?? 2
            return (day: day, mood: moodValue)
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(max(1, moodData.count - 1))
                let stepY = height / CGFloat(maxMoodValue)
                
                // Y-axis labels
                ForEach(0...maxMoodValue, id: \.self) { level in
                    let mood = RevisionStore.DailyRevision.Mood.allCases[level]
                    let yPosition = height - (CGFloat(level) * stepY)
                    
                    HStack {
                        Text(mood.rawValue)
                            .font(.caption)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                        Spacer()
                    }
                    .offset(y: yPosition - 10)
                }
                // Chart line
                Path { path in
                    for (index, data) in moodData.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(data.mood) * stepY)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(settings.currentTheme.accentColor, lineWidth: 2)
                
                // Data points
                ForEach(Array(moodData.enumerated()), id: \.offset) { index, data in
                    let x = CGFloat(index) * stepX
                    let y = height - (CGFloat(data.mood) * stepY)
                    
                    Circle()
                        .fill(settings.currentTheme.accentColor)
                        .frame(width: 8, height: 8)
                        .offset(x: x - 4, y: y - 4)
                    
                    Text(data.day)
                        .font(.caption)
                        .foregroundColor(settings.currentTheme.textColor)
                        .offset(x: x - 10, y: height - 20)
                }
            }
        }
    }
}

struct RevisionMetricPill: View {
    @EnvironmentObject var settings: SettingsStore
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
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
}
