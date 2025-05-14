import SwiftUI

// MARK: - Theme System
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light
    case darkGold
    case cyberpunk
    
    var id: String { self.rawValue }
    
    var primaryColor: Color {
        switch self {
        case .light: return .africanSun
        case .darkGold: return .gold
        case .cyberpunk: return .neonPink
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .light: return .africanSoil
        case .darkGold: return .darkGray
        case .cyberpunk: return .neonBlue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .light: return .white
        case .darkGold: return .black
        case .cyberpunk: return .darkPurple
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return .black
        case .darkGold: return .gold
        case .cyberpunk: return .neonGreen
        }
    }
    
    var accentColor: Color {
        switch self {
        case .light: return .kenteRed
        case .darkGold: return .gold
        case .cyberpunk: return .neonPurple
        }
    }
}

// MARK: - Color Extensions
extension Color {
    // African Theme Colors
    static let africanSun = Color(red: 0.85, green: 0.55, blue: 0.13)
    static let africanSoil = Color(red: 0.45, green: 0.25, blue: 0.15)
    static let africanSky = Color(red: 0.20, green: 0.40, blue: 0.60)
    static let africanLeaf = Color(red: 0.20, green: 0.50, blue: 0.20)
    static let africanClay = Color(red: 0.75, green: 0.35, blue: 0.25)
    static let kenteYellow = Color(red: 1.00, green: 0.80, blue: 0.00)
    static let kenteRed = Color(red: 0.75, green: 0.15, blue: 0.15)
    static let kenteGreen = Color(red: 0.00, green: 0.50, blue: 0.25)
    static let adinkraOrange = Color(red: 0.90, green: 0.40, blue: 0.10)
    
    // Dark Gold Theme Colors
    static let gold = Color(red: 0.83, green: 0.69, blue: 0.22)
    static let darkGray = Color(red: 0.1, green: 0.1, blue: 0.1)
    
    // Cyberpunk Theme Colors
    static let neonPink = Color(red: 1.00, green: 0.07, blue: 0.57)
    static let neonBlue = Color(red: 0.30, green: 0.85, blue: 1.00)
    static let neonGreen = Color(red: 0.30, green: 1.00, blue: 0.50)
    static let neonPurple = Color(red: 0.70, green: 0.30, blue: 1.00)
    static let darkPurple = Color(red: 0.15, green: 0.05, blue: 0.30)
}

// MARK: - Models
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var startDate: Date
    var endDate: Date
    var color: TaskColor
    var recurrence: Recurrence?
    
    enum TaskColor: String, CaseIterable, Codable {
        case red, orange, yellow, green, blue, purple, pink
    }
    
    enum Recurrence: String, CaseIterable, Codable {
        case none = "none"
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
    }
    
    init(id: UUID = UUID(),
         title: String,
         notes: String = "",
         isCompleted: Bool = false,
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(3600),
         color: TaskColor = .blue,
         recurrence: Recurrence? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.recurrence = recurrence
    }
}

struct IncomeRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    
    init(id: UUID = UUID(), date: Date = Date(), amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

struct HealthRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var waterIntake: Double // in liters
    var sleepHours: Double
    var caloriesConsumed: Int
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         waterIntake: Double = 0,
         sleepHours: Double = 0,
         caloriesConsumed: Int = 0) {
        self.id = id
        self.date = date
        self.waterIntake = waterIntake
        self.sleepHours = sleepHours
        self.caloriesConsumed = caloriesConsumed
    }
}

struct StatusRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var followers: Int
    var posts: Int
    var engagement: Double // percentage
    var minutesSpent: Int
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         followers: Int = 0,
         posts: Int = 0,
         engagement: Double = 0,
         minutesSpent: Int = 0) {
        self.id = id
        self.date = date
        self.followers = followers
        self.posts = posts
        self.engagement = engagement
        self.minutesSpent = minutesSpent
    }
}

// MARK: - ViewModels
class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedDate = Date()
    
    init() {
        loadTasks()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter {
            calendar.isDate($0.startDate, inSameDayAs: date)
        }
    }
    
    func tasksForWeek(containing date: Date) -> [Date: [Task]] {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfYear, for: date)
        var result: [Date: [Task]] = [:]
        
        guard let week = week else { return result }
        
        calendar.enumerateDates(startingAfter: week.start,
                               matching: DateComponents(hour: 0, minute: 0, second: 0),
                               matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date, date < week.end else {
                stop = true
                return
            }
            result[date] = tasksForDate(date)
        }
        
        return result
    }
    
    func tasksForMonth(containing date: Date) -> [Date: [Task]] {
        let calendar = Calendar.current
        let month = calendar.dateInterval(of: .month, for: date)
        var result: [Date: [Task]] = [:]
        
        guard let month = month else { return result }
        
        calendar.enumerateDates(startingAfter: month.start,
                               matching: DateComponents(hour: 0, minute: 0, second: 0),
                               matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date, date < month.end else {
                stop = true
                return
            }
            result[date] = tasksForDate(date)
        }
        
        return result
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}

class IncomeStore: ObservableObject {
    @Published var records: [IncomeRecord] = []
    
    init() {
        loadRecords()
    }
    
    func addRecord(amount: Double, date: Date = Date()) {
        let newRecord = IncomeRecord(date: date, amount: amount)
        records.append(newRecord)
        saveRecords()
    }
    
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveRecords()
    }
    
    func weeklyTotal() -> Double {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        return records.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek
        }.reduce(0) { $0 + $1.amount }
    }
    
    func monthlyTotal() -> Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        return records.filter {
            calendar.component(.month, from: $0.date) == currentMonth
        }.reduce(0) { $0 + $1.amount }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "incomeRecords")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "incomeRecords"),
           let decoded = try? JSONDecoder().decode([IncomeRecord].self, from: data) {
            records = decoded
        }
    }
}

class HealthStore: ObservableObject {
    @Published var records: [HealthRecord] = []
    
    init() {
        loadRecords()
    }
    
    func addRecord(water: Double, sleep: Double, calories: Int, date: Date = Date()) {
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            records[index].waterIntake += water
            records[index].sleepHours += sleep
            records[index].caloriesConsumed += calories
        } else {
            let newRecord = HealthRecord(date: date, waterIntake: water, sleepHours: sleep, caloriesConsumed: calories)
            records.append(newRecord)
        }
        saveRecords()
    }
    
    func todaysRecord() -> HealthRecord {
        let today = Calendar.current.startOfDay(for: Date())
        return records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) ??
               HealthRecord(date: today, waterIntake: 0, sleepHours: 0, caloriesConsumed: 0)
    }
    
    func weeklyAverage() -> (water: Double, sleep: Double, calories: Int) {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let weeklyRecords = records.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek
        }
        
        let totalWater = weeklyRecords.reduce(0) { $0 + $1.waterIntake }
        let totalSleep = weeklyRecords.reduce(0) { $0 + $1.sleepHours }
        let totalCalories = weeklyRecords.reduce(0) { $0 + $1.caloriesConsumed }
        let count = max(weeklyRecords.count, 1)
        
        return (totalWater/Double(count), totalSleep/Double(count), totalCalories/count)
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "healthRecords")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "healthRecords"),
           let decoded = try? JSONDecoder().decode([HealthRecord].self, from: data) {
            records = decoded
        }
    }
}

class StatusStore: ObservableObject {
    @Published var records: [StatusRecord] = []
    
    init() {
        loadRecords()
    }
    
    func addRecord(followers: Int, posts: Int, engagement: Double, minutesSpent: Int, date: Date = Date()) {
        let newRecord = StatusRecord(date: date, followers: followers, posts: posts, engagement: engagement, minutesSpent: minutesSpent)
        records.append(newRecord)
        saveRecords()
    }
    
    func weeklyGrowth() -> (followers: Int, posts: Int, engagement: Double, minutes: Int) {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let weeklyRecords = records.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek
        }
        
        guard !weeklyRecords.isEmpty else { return (0, 0, 0, 0) }
        
        let firstRecord = weeklyRecords.first!
        let lastRecord = weeklyRecords.last!
        
        return (
            lastRecord.followers - firstRecord.followers,
            lastRecord.posts - firstRecord.posts,
            lastRecord.engagement - firstRecord.engagement,
            weeklyRecords.reduce(0) { $0 + $1.minutesSpent }
        )
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "statusRecords")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "statusRecords"),
           let decoded = try? JSONDecoder().decode([StatusRecord].self, from: data) {
            records = decoded
        }
    }
}

class SettingsStore: ObservableObject {
    @Published var currentTheme: AppTheme = .light {
        didSet {
            saveSettings()
            UITabBar.updateAppearance(theme: currentTheme)
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    init() {
        loadSettings()
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(encoded, forKey: "appTheme")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "appTheme"),
           let decoded = try? JSONDecoder().decode(AppTheme.self, from: data) {
            currentTheme = decoded
        }
    }
}

// MARK: - Views
struct ContentView: View {
    @StateObject private var taskStore = TaskStore()
    @StateObject private var incomeStore = IncomeStore()
    @StateObject private var healthStore = HealthStore()
    @StateObject private var statusStore = StatusStore()
    @StateObject private var settingsStore = SettingsStore()
    @State private var selectedTab: Tab = .tasks
    @State private var forceRefresh = false
    
    enum Tab {
        case tasks
        case income
        case health
        case status
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TaskView(taskStore: taskStore)
                .tabItem {
                    Label("Tasks", systemImage: "calendar")
                }
                .tag(Tab.tasks)
            
            IncomeView(incomeStore: incomeStore)
                .tabItem {
                    Label("Income", systemImage: "dollarsign.circle")
                }
                .tag(Tab.income)
            
            HealthView(healthStore: healthStore)
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                .tag(Tab.health)
            
            StatusView()
                .tabItem {
                    Label("Status", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.status)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .accentColor(settingsStore.currentTheme.accentColor)
        .environmentObject(settingsStore)
        .onAppear {
            setupAppearance(theme: settingsStore.currentTheme)
        }
        .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
            setupAppearance(theme: settingsStore.currentTheme)
        }
        .id(forceRefresh)
    }
    
    private func setupAppearance(theme: AppTheme) {
        UITabBar.appearance().backgroundColor = UIColor(theme.backgroundColor)
        UITabBar.appearance().unselectedItemTintColor = UIColor(theme.textColor.opacity(0.6))
        UITabBar.appearance().barTintColor = UIColor(theme.backgroundColor)
    }
}

// MARK: - Task View
struct TaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @State private var showingAddTask = false
    @State private var viewMode: ViewMode = .week
    
    enum ViewMode: String, CaseIterable {
        case day, week, month
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Calendar Header
                    CalendarHeaderView(
                        selectedDate: $taskStore.selectedDate,
                        viewMode: $viewMode
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Calendar Content
                    switch viewMode {
                    case .day:
                        DayView(taskStore: taskStore)
                    case .week:
                        WeekView(taskStore: taskStore)
                    case .month:
                        MonthView(taskStore: taskStore)
                    }
                }
                .navigationTitle(titleForSelectedDate())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddTask = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensures button works properly
                    }
                }
            }
            // Sheet modifier must be attached to the NavigationView
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskStore: taskStore)
                    .environmentObject(settings)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func titleForSelectedDate() -> String {
        let formatter = DateFormatter()
        switch viewMode {
        case .day:
            formatter.dateFormat = "EEEE, MMM d, yyyy"
        case .week:
            formatter.dateFormat = "MMMM yyyy"
            return "Week of \(formatter.string(from: taskStore.selectedDate))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: taskStore.selectedDate)
    }
}

struct CalendarHeaderView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedDate: Date
    @Binding var viewMode: TaskView.ViewMode
    
    var body: some View {
        HStack {
            Button(action: moveToPrevious) {
                Image(systemName: "chevron.left")
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            Spacer()
            
            Picker("View Mode", selection: $viewMode) {
                ForEach(TaskView.ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized)
                        .tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
            
            Spacer()
            
            Button(action: moveToNext) {
                Image(systemName: "chevron.right")
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            Button("Today") {
                selectedDate = Date()
            }
            .foregroundColor(settings.currentTheme.accentColor)
        }
    }
    
    private func moveToPrevious() {
        withAnimation {
            let calendar = Calendar.current
            switch viewMode {
            case .day:
                selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)!
            case .week:
                selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate)!
            case .month:
                selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
            }
        }
    }
    
    private func moveToNext() {
        withAnimation {
            let calendar = Calendar.current
            switch viewMode {
            case .day:
                selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
            case .week:
                selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate)!
            case .month:
                selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
            }
        }
    }
}

struct CurrentTimeIndicator: View {
    @State private var currentTime = Date()
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        GeometryReader { geometry in
            let minutes = Calendar.current.component(.hour, from: currentTime) * 60 +
                          Calendar.current.component(.minute, from: currentTime)
            let position = CGFloat(minutes) / (24 * 60) * geometry.size.height
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(settings.currentTheme.accentColor)
                    .frame(height: 2)
                
                Circle()
                    .fill(settings.currentTheme.accentColor)
                    .frame(width: 10, height: 10)
            }
            .position(x: geometry.size.width / 2, y: position)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    currentTime = Date()
                }
            }
        }
        .frame(height: 24 * 60)
    }
}

struct DayView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    
    private let hours = Array(0..<24)
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // Time labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HourRow(hour: hour)
                            .frame(height: 60)
                    }
                }
                .frame(width: 60)
                .padding(.trailing, 8)
                
                // Events grid
                GeometryReader { geometry in
                    ForEach(taskStore.tasksForDate(taskStore.selectedDate)) { task in
                        CalendarEvent(task: task, parentWidth: geometry.size.width - 70)
                    }
                }
                .padding(.leading, 70)
            }
            .padding()
        }
    }
}

struct HourRow: View {
    @EnvironmentObject var settings: SettingsStore
    let hour: Int
    
    var body: some View {
        HStack {
            Text("\(hour == 0 ? 12 : hour > 12 ? hour - 12 : hour) \(hour < 12 ? "AM" : "PM")")
                .font(.caption)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            
            Rectangle()
                .fill(settings.currentTheme.textColor.opacity(0.2))
                .frame(height: 1)
        }
    }
}

struct CalendarEvent: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    let parentWidth: CGFloat
    
    private var startPosition: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: task.startDate)
        let minute = calendar.component(.minute, from: task.startDate)
        return CGFloat(hour * 60 + minute)
    }
    
    private var duration: CGFloat {
        let duration = task.endDate.timeIntervalSince(task.startDate) / 60
        return CGFloat(duration)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text("\(DateFormatter.timeFormatter.string(from: task.startDate)) - \(DateFormatter.timeFormatter.string(from: task.endDate))")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(8)
        .frame(width: parentWidth - 16, height: duration)
        .background(Color(task.color.rawValue))
        .cornerRadius(8)
        .offset(y: startPosition)
    }
}

struct WeekView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    
    private let days = Array(0..<7)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Day headers
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: 60, height: 40)
                    
                    ForEach(days, id: \.self) { day in
                        let date = Calendar.current.date(byAdding: .day, value: day, to: weekStartDate())!
                        DayHeader(date: date)
                    }
                }
                
                // Time grid
                HStack(spacing: 0) {
                    TimeColumn()
                    
                    ForEach(days, id: \.self) { day in
                        let date = Calendar.current.date(byAdding: .day, value: day, to: weekStartDate())!
                        DayColumn(taskStore: taskStore, date: date)
                    }
                }
            }
        }
    }
    
    private func weekStartDate() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: taskStore.selectedDate))!
    }
}

struct MonthView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    DayCell(taskStore: taskStore, date: date)
                }
            }
            .padding()
        }
    }
    
    private func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: taskStore.selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDates(for: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
}

struct AddTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var notes = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // 1 hour later
    @State private var color: Task.TaskColor = .blue
    @State private var recurrence: Task.Recurrence = .none
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").foregroundColor(settings.currentTheme.accentColor)) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                    
                    DatePicker("Start Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Time", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Color", selection: $color) {
                        ForEach(Task.TaskColor.allCases, id: \.self) { color in
                            Text(color.rawValue.capitalized).tag(color)
                        }
                    }
                    
                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(Task.Recurrence.allCases, id: \.self) { recurrence in
                            Text(recurrence.rawValue.capitalized).tag(recurrence)
                        }
                    }
                }
                
                Section {
                    Button(action: addTask) {
                        Text("Add Task")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addTask() {
        let newTask = Task(
            title: title,
            notes: notes,
            startDate: startDate,
            endDate: endDate,
            color: color,
            recurrence: recurrence
        )
        taskStore.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

struct DayCell: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    let date: Date
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: taskStore.selectedDate, toGranularity: .month)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14))
                .foregroundColor(
                    isToday ? settings.currentTheme.accentColor :
                    isCurrentMonth ? settings.currentTheme.textColor :
                    settings.currentTheme.textColor.opacity(0.5)
                )
                .frame(width: 24, height: 24)
                .background(isToday ? settings.currentTheme.accentColor.opacity(0.2) : Color.clear)
                .clipShape(Circle())
            
            ForEach(taskStore.tasksForDate(date).prefix(2)) { task in
                Text(task.title)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(task.color.rawValue).opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            if taskStore.tasksForDate(date).count > 2 {
                Text("+\(taskStore.tasksForDate(date).count - 2) more")
                    .font(.caption2)
                    .foregroundColor(settings.currentTheme.accentColor)
            }
        }
        .padding(4)
        .frame(height: 80)
        .background(
            isCurrentMonth ? settings.currentTheme.backgroundColor :
            settings.currentTheme.backgroundColor.opacity(0.5)
        )
        .cornerRadius(8)
        .onTapGesture {
            withAnimation {
                taskStore.selectedDate = date
            }
        }
    }
}

struct DayHeader: View {
    @EnvironmentObject var settings: SettingsStore
    let date: Date
    
    var body: some View {
        VStack {
            Text(DateFormatter.dayFormatter.string(from: date).prefix(3))
                .font(.caption)
                .foregroundColor(settings.currentTheme.textColor)
            
            Text(DateFormatter.dateFormatter.string(from: date))
                .font(.caption2)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(settings.currentTheme.backgroundColor.opacity(0.8))
        .overlay(
            Rectangle()
                .frame(width: 1, height: nil, alignment: .trailing)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.2)),
            alignment: .trailing
        )
    }
}

struct TimeColumn: View {
    @EnvironmentObject var settings: SettingsStore
    private let hours = Array(0..<24)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                Text("\(hour == 0 ? 12 : hour > 12 ? hour - 12 : hour) \(hour < 12 ? "AM" : "PM")")
                    .font(.caption2)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    .frame(width: 60, height: 60, alignment: .topTrailing)
                    .padding(.trailing, 4)
                    .overlay(
                        Rectangle()
                            .frame(height: 1, alignment: .bottom)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.1)),
                        alignment: .bottom
                    )
            }
        }
    }
}

struct DayColumn: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    let date: Date
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                ForEach(0..<24, id: \.self) { _ in
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.1))
                }
                
                // Events
                ForEach(taskStore.tasksForDate(date)) { task in
                    CalendarEvent(task: task, parentWidth: geometry.size.width)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(
            Rectangle()
                .frame(width: 1, height: nil, alignment: .trailing)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.2)),
            alignment: .trailing
        )
    }
}

// MARK: - Income Views
struct IncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @State private var showingAddIncome = false
    @State private var incomeAmount = ""
    @State private var incomeDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary Cards
                        HStack(spacing: 16) {
                            SummaryCard(title: "Today", amount: todayTotal(), color: settings.currentTheme.accentColor)
                            SummaryCard(title: "This Week", amount: incomeStore.weeklyTotal(), color: settings.currentTheme.primaryColor)
                            SummaryCard(title: "This Month", amount: incomeStore.monthlyTotal(), color: settings.currentTheme.secondaryColor)
                        }
                        .padding(.horizontal)
                        
                        // Calendar View
                        CalendarView(incomeStore: incomeStore)
                            .frame(height: 300)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                                          settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                                          Color.white)
                                    .shadow(color: settings.currentTheme.textColor.opacity(0.1), radius: 5)
                            )
                            .padding(.horizontal)
                        
                        // Income List
                        VStack(alignment: .leading) {
                            Text("Recent Income")
                                .font(.headline)
                                .foregroundColor(settings.currentTheme.textColor)
                                .padding(.leading)
                            
                            ForEach(incomeStore.records.sorted(by: { $0.date > $1.date }).prefix(5)) { record in
                                IncomeRow(record: record)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                                                settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                                                Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .shadow(color: settings.currentTheme.textColor.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Income Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddIncome = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddIncome) {
                    AddIncomeView(incomeStore: incomeStore)
                }
            }
        }
    }
    
    private func todayTotal() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return incomeStore.records.filter {
            calendar.startOfDay(for: $0.date) == today
        }.reduce(0) { $0 + $1.amount }
    }
}

struct SummaryCard: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Text(amount, format: .currency(code: "USD"))
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct CalendarView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack {
            // Month and year header
            HStack {
                Text(currentDate, format: .dateTime.year().month())
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(settings.currentTheme.accentColor)
                }
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(settings.currentTheme.accentColor)
                }
            }
            .padding(.bottom, 8)
            
            // Days of week header
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(settings.currentTheme.textColor)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if calendar.isDate(date, equalTo: currentDate, toGranularity: .month) {
                        CalendarDayView(date: date, incomeStore: incomeStore)
                    } else {
                        Text("")
                    }
                }
            }
        }
        .foregroundColor(settings.currentTheme.textColor)
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDates(for: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
    
    private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
    }
    
    private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
    }
}

struct CalendarDayView: View {
    @EnvironmentObject var settings: SettingsStore
    let date: Date
    @ObservedObject var incomeStore: IncomeStore
    
    private var dayIncome: Double {
        incomeStore.records.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(Calendar.current.component(.day, from: date)))
                .font(.system(size: 14))
                .foregroundColor(isToday ? .white : settings.currentTheme.textColor)
                .frame(width: 24, height: 24)
                .background(isToday ? settings.currentTheme.accentColor : Color.clear)
                .clipShape(Circle())
            
            if dayIncome > 0 {
                Text(dayIncome, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 10))
                    .foregroundColor(settings.currentTheme == .cyberpunk ? .neonGreen : .kenteGreen)
            }
        }
        .frame(height: 40)
    }
}

struct IncomeRow: View {
    @EnvironmentObject var settings: SettingsStore
    let record: IncomeRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.date, format: .dateTime.day().month().year())
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Text(record.date, format: .dateTime.weekday(.wide))
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Spacer()
            
            Text(record.amount, format: .currency(code: "USD"))
                .font(.title3.bold())
                .foregroundColor(settings.currentTheme.accentColor)
        }
        .padding(.vertical, 8)
    }
}

struct AddIncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @State private var amount = ""
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Income Details").foregroundColor(settings.currentTheme.accentColor)) {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(settings.currentTheme.textColor)
                            .colorScheme(settings.currentTheme == .darkGold ? .dark : .light)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: {
                            if let amountValue = Double(amount) {
                                incomeStore.addRecord(amount: amountValue, date: date)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Add Income")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
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
                        .disabled(amount.isEmpty || Double(amount) == nil)
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Add Income")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
        }
        .accentColor(settings.currentTheme.accentColor)
    }
}

// MARK: - Health Views
struct HealthView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var healthStore: HealthStore
    @State private var showingAddHealth = false
    @State private var waterIntake = ""
    @State private var sleepHours = ""
    @State private var caloriesConsumed = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Summary
                        VStack(spacing: 16) {
                            Text("Today's Health")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                HealthMetricCard(
                                    title: "Water",
                                    value: String(format: "%.1f L", healthStore.todaysRecord().waterIntake),
                                    goal: "2.5 L",
                                    progress: healthStore.todaysRecord().waterIntake / 2.5,
                                    color: .blue
                                )
                                
                                HealthMetricCard(
                                    title: "Sleep",
                                    value: String(format: "%.1f hrs", healthStore.todaysRecord().sleepHours),
                                    goal: "8 hrs",
                                    progress: healthStore.todaysRecord().sleepHours / 8,
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                            
                            HealthMetricCard(
                                title: "Calories",
                                value: "\(healthStore.todaysRecord().caloriesConsumed)",
                                goal: "2000 kcal",
                                progress: Double(healthStore.todaysRecord().caloriesConsumed) / 2000,
                                color: .orange
                            )
                            .padding(.horizontal)
                        }
                        
                        // Weekly Averages
                        VStack(spacing: 16) {
                            Text("Weekly Averages")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            let averages = healthStore.weeklyAverage()
                            
                            HStack(spacing: 16) {
                                HealthMetricCard(
                                    title: "Avg Water",
                                    value: String(format: "%.1f L", averages.water),
                                    goal: "2.5 L",
                                    progress: averages.water / 2.5,
                                    color: .blue
                                )
                                
                                HealthMetricCard(
                                    title: "Avg Sleep",
                                    value: String(format: "%.1f hrs", averages.sleep),
                                    goal: "8 hrs",
                                    progress: averages.sleep / 8,
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                            
                            HealthMetricCard(
                                title: "Avg Calories",
                                value: "\(averages.calories)",
                                goal: "2000 kcal",
                                progress: Double(averages.calories) / 2000,
                                color: .orange
                            )
                            .padding(.horizontal)
                        }
                        
                        // Recent Records
                        VStack(alignment: .leading) {
                            Text("Recent Records")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .padding(.horizontal)
                            
                            ForEach(healthStore.records.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                HealthRecordRow(record: record)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                                                settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                                                Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .shadow(color: settings.currentTheme.textColor.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Health Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddHealth = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddHealth) {
                    AddHealthView(healthStore: healthStore)
                }
            }
        }
    }
}

struct HealthMetricCard: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let value: String
    let goal: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text(value)
                    .font(.body.bold())
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            HStack {
                Text("Goal: \(goal)")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(settings.currentTheme.textColor)
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.1) :
                    settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.05) :
                    Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(settings.currentTheme.textColor.opacity(0.1), lineWidth: 1)
        )
    }
}

struct HealthRecordRow: View {
    @EnvironmentObject var settings: SettingsStore
    let record: HealthRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.date, format: .dateTime.day().month().year())
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            HStack {
                HealthMetricPill(
                    value: String(format: "%.1f L", record.waterIntake),
                    label: "Water",
                    color: .blue
                )
                HealthMetricPill(
                                    value: String(format: "%.1f hrs", record.sleepHours),
                                    label: "Sleep",
                                    color: .purple
                                )
                HealthMetricPill(value: "\(record.caloriesConsumed)", label: "Calories", color: .orange)
            }
        }
    }
}

struct HealthMetricPill: View {
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
        .background(color.opacity(0.2))
        .cornerRadius(20)
    }
}

struct AddHealthView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var healthStore: HealthStore
    @State private var waterIntake = ""
    @State private var sleepHours = ""
    @State private var caloriesConsumed = ""
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Health Details").foregroundColor(settings.currentTheme.accentColor)) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                        
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            TextField("Water (L)", text: $waterIntake)
                                .keyboardType(.decimalPad)
                        }
                        
                        HStack {
                            Image(systemName: "moon.zzz.fill")
                                .foregroundColor(.purple)
                            TextField("Sleep (hours)", text: $sleepHours)
                                .keyboardType(.decimalPad)
                        }
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            TextField("Calories", text: $caloriesConsumed)
                                .keyboardType(.numberPad)
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: {
                            if let water = Double(waterIntake),
                               let sleep = Double(sleepHours),
                               let calories = Int(caloriesConsumed) {
                                healthStore.addRecord(water: water, sleep: sleep, calories: calories, date: date)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Add Health Data")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
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
                        .disabled(waterIntake.isEmpty || sleepHours.isEmpty || caloriesConsumed.isEmpty)
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Add Health Data")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
        }
        .accentColor(settings.currentTheme.accentColor)
    }
}

//MARK: - Status View
struct StatusView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var statusStore = StatusStore()
    @State private var showingAddStatus = false
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Growth Summary
                        let growth = statusStore.weeklyGrowth()
                        
                        HStack(spacing: 16) {
                            StatusMetricCard(
                                title: "New Followers",
                                value: "\(growth.followers)",
                                trend: growth.followers >= 0 ? "up" : "down",
                                color: .green
                            )
                            
                            StatusMetricCard(
                                title: "Content Posted",
                                value: "\(growth.posts)",
                                trend: growth.posts >= 0 ? "up" : "down",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            StatusMetricCard(
                                title: "Engagement",
                                value: String(format: "%.1f%%", growth.engagement),
                                trend: growth.engagement >= 0 ? "up" : "down",
                                color: .purple
                            )
                            
                            StatusMetricCard(
                                title: "Time Invested",
                                value: "\(growth.minutes) min",
                                trend: "none",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Recent Records
                        VStack(alignment: .leading) {
                            Text("Recent Updates")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .padding(.horizontal)
                            
                            ForEach(statusStore.records.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                StatusRecordRow(record: record)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Social Growth")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddStatus = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddStatus) {
                    AddStatusView(statusStore: statusStore)
                }
            }
        }
    }
}

struct StatusMetricCard: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let value: String
    let trend: String // "up", "down", or "none"
    let color: Color
    
    var trendIcon: String {
        switch trend {
        case "up": return "arrow.up"
        case "down": return "arrow.down"
        default: return "minus"
        }
    }
    
    var trendColor: Color {
        switch trend {
        case "up": return .green
        case "down": return .red
        default: return settings.currentTheme.textColor.opacity(0.7)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                
                if trend != "none" {
                    Image(systemName: trendIcon)
                        .foregroundColor(trendColor)
                }
            }
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(settings.currentTheme.textColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                    settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                    Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct StatusRecordRow: View {
    @EnvironmentObject var settings: SettingsStore
    let record: StatusRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(record.date, format: .dateTime.day().month().year())
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            HStack(spacing: 16) {
                StatusPill(value: "\(record.followers)", label: "Followers", color: .green)
                StatusPill(value: "\(record.posts)", label: "Posts", color: .blue)
                StatusPill(value: "\(record.engagement)%", label: "Engagement", color: .purple)
                StatusPill(value: "\(record.minutesSpent)m", label: "Time", color: .orange)
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                    settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                    Color.white)
        .cornerRadius(10)
        .shadow(color: settings.currentTheme.textColor.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct StatusPill: View {
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
        .background(color.opacity(0.2))
        .cornerRadius(20)
    }
}

struct AddStatusView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var statusStore: StatusStore
    @State private var followers = ""
    @State private var posts = ""
    @State private var engagement = ""
    @State private var minutesSpent = ""
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Status Details").foregroundColor(settings.currentTheme.accentColor)) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                        
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.green)
                            TextField("Followers Count", text: $followers)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Image(systemName: "photo.stack.fill")
                                .foregroundColor(.blue)
                            TextField("Posts Today", text: $posts)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.purple)
                            TextField("Engagement %", text: $engagement)
                                .keyboardType(.decimalPad)
                        }

                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            TextField("Minutes Spent", text: $minutesSpent)
                                .keyboardType(.numberPad)
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: addStatusData) {
                            HStack {
                                Spacer()
                                Text("Save Status")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
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
                        .disabled(followers.isEmpty || posts.isEmpty || engagement.isEmpty || minutesSpent.isEmpty)
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Add Status")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
        }
        .accentColor(settings.currentTheme.accentColor)
    }
    
    private func addStatusData() {
        if let followersValue = Int(followers),
           let postsValue = Int(posts),
           let engagementValue = Double(engagement),
           let minutesValue = Int(minutesSpent) {
            statusStore.addRecord(
                followers: followersValue,
                posts: postsValue,
                engagement: engagementValue,
                minutesSpent: minutesValue,
                date: date
            )
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Appearance").foregroundColor(settings.currentTheme.accentColor)) {
                        Picker("Theme", selection: $settings.currentTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue.capitalized).tag(theme)
                                    .foregroundColor(settings.currentTheme.textColor)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .colorMultiply(settings.currentTheme.primaryColor)
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section(header: Text("About").foregroundColor(settings.currentTheme.accentColor)) {
                        HStack {
                            Text("Version")
                                .foregroundColor(settings.currentTheme.textColor)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                        }
                        
                        HStack {
                            Text("Build")
                                .foregroundColor(settings.currentTheme.textColor)
                            Spacer()
                            Text("100")
                                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                }
                .scrollContentBackground(.hidden) // This hides the default white background
                .background(settings.currentTheme.backgroundColor)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Extensions
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
