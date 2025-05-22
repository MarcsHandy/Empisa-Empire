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

enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    var id: Int { self.rawValue }
    
    var shortName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.shortWeekdaySymbols[rawValue - 1]
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
    var recurrenceDays: [Int]? // Days of week (1=Sunday, 2=Monday, etc.)
    
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
    
    // Update your initializer to include recurrenceDays
    init(id: UUID = UUID(),
         title: String,
         notes: String = "",
         isCompleted: Bool = false,
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(3600),
         color: TaskColor = .blue,
         recurrence: Recurrence? = nil,
         recurrenceDays: [Int]? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.recurrence = recurrence
        self.recurrenceDays = recurrenceDays
    }
    
    var occursOnDate: (_ date: Date) -> Bool {
            return { date in
                let calendar = Calendar.current
                
                // If it's the original task date
                if calendar.isDate(date, inSameDayAs: self.startDate) {
                    return true
                }
                
                // If it's not a recurring task, only show on original date
                guard let recurrence = self.recurrence, date > self.startDate else {
                    return false
                }
                
                switch recurrence {
                case .daily:
                    return true
                    
                case .weekly:
                    if let recurrenceDays = self.recurrenceDays {
                        let weekday = calendar.component(.weekday, from: date)
                        return recurrenceDays.contains(weekday)
                    } else {
                        // Default to same weekday if no days specified
                        let originalWeekday = calendar.component(.weekday, from: self.startDate)
                        let currentWeekday = calendar.component(.weekday, from: date)
                        return originalWeekday == currentWeekday
                    }
                    
                case .monthly:
                    let originalDay = calendar.component(.day, from: self.startDate)
                    let currentDay = calendar.component(.day, from: date)
                    return originalDay == currentDay
                    
                case .yearly:
                    let originalComponents = calendar.dateComponents([.month, .day], from: self.startDate)
                    let currentComponents = calendar.dateComponents([.month, .day], from: date)
                    return originalComponents.month == currentComponents.month &&
                           originalComponents.day == currentComponents.day
                    
                case .none:
                    return false
                }
            }
        }
}

struct IncomeRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var amount: Double
    
    init(id: UUID = UUID(), date: Date = Date(), amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    var isRecurring: Bool
    var recurrence: Recurrence?
    
    enum ExpenseCategory: String, CaseIterable, Codable {
        case housing = "Housing"
        case food = "Food"
        case transportation = "Transportation"
        case entertainment = "Entertainment"
        case utilities = "Utilities"
        case health = "Health"
        case shopping = "Shopping"
        case other = "Other"
    }
    
    enum Recurrence: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
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
    
    func saveTasks() {
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
    
    func todayTotal() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return records.filter {
            calendar.isDate($0.date, inSameDayAs: today)
        }.reduce(0) { $0 + $1.amount }
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

class ExpenseStore: ObservableObject {
    @Published var expenses: [Expense] = []
    
    init() {
        loadExpenses()
        checkRecurringExpenses()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }
    
    func deleteExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses.remove(at: index)
            saveExpenses()
        }
    }
    
    func expensesForDate(_ date: Date) -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter { expense in
            if expense.isRecurring, let recurrence = expense.recurrence {
                switch recurrence {
                case .daily:
                    return true
                case .weekly:
                    return calendar.component(.weekday, from: date) == calendar.component(.weekday, from: expense.date)
                case .monthly:
                    return calendar.component(.day, from: date) == calendar.component(.day, from: expense.date)
                case .yearly:
                    let expenseComponents = calendar.dateComponents([.month, .day], from: expense.date)
                    let dateComponents = calendar.dateComponents([.month, .day], from: date)
                    return expenseComponents.month == dateComponents.month && expenseComponents.day == dateComponents.day
                }
            } else {
                return calendar.isDate(expense.date, inSameDayAs: date)
            }
        }
    }
    
    func todayTotal() -> Double {
        expensesForDate(Date()).reduce(0) { $0 + $1.amount }
    }
    
    func weeklyTotal() -> Double {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        return expenses.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek ||
            ($0.isRecurring && $0.recurrence == .weekly)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func monthlyTotal() -> Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        return expenses.filter {
            calendar.component(.month, from: $0.date) == currentMonth ||
            ($0.isRecurring && $0.recurrence == .monthly)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private func checkRecurringExpenses() {
        let today = Calendar.current.startOfDay(for: Date())
        for expense in expenses where expense.isRecurring {
            if !expensesForDate(today).contains(where: { $0.id == expense.id }) {
                let newExpense = Expense(
                    id: UUID(),
                    title: expense.title,
                    amount: expense.amount,
                    date: today,
                    category: expense.category,
                    isRecurring: true,
                    recurrence: expense.recurrence
                )
                expenses.append(newExpense)
            }
        }
        saveExpenses()
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
    }
    
    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: "expenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
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
    
    func recordForDate(_ date: Date) -> HealthRecord? {
        let calendar = Calendar.current
        return records.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func updateRecord(_ record: HealthRecord) {
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: record.date) }) {
            records[index] = record
        } else {
            records.append(record)
        }
        saveRecords()
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

class RevisionStore: ObservableObject {
    @Published var dailyRevisions: [DailyRevision] = []
    
    struct DailyRevision: Identifiable, Codable {
        let id: UUID
        let date: Date
        var whatWentWell: String
        var whatToImprove: String
        var lessonsLearned: String
        var tomorrowFocus: String
        
        init(id: UUID = UUID(),
             date: Date = Date(),
             whatWentWell: String = "",
             whatToImprove: String = "",
             lessonsLearned: String = "",
             tomorrowFocus: String = "") {
            self.id = id
            self.date = date
            self.whatWentWell = whatWentWell
            self.whatToImprove = whatToImprove
            self.lessonsLearned = lessonsLearned
            self.tomorrowFocus = tomorrowFocus
        }
    }
    
    func addRevision(_ revision: DailyRevision) {
        dailyRevisions.append(revision)
        saveRevisions()
    }
    
    func getTodaysRevision() -> DailyRevision {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyRevisions.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) ??
               DailyRevision(date: today)
    }
    
    private func saveRevisions() {
        if let encoded = try? JSONEncoder().encode(dailyRevisions) {
            UserDefaults.standard.set(encoded, forKey: "dailyRevisions")
        }
    }
    
    private func loadRevisions() {
        if let data = UserDefaults.standard.data(forKey: "dailyRevisions"),
           let decoded = try? JSONDecoder().decode([DailyRevision].self, from: data) {
            dailyRevisions = decoded
        }
    }
    
    init() {
        loadRevisions()
    }
}

class GoalsStore: ObservableObject {
    @Published var goals: [Goal] = []
    
    enum GoalType: String, CaseIterable, Codable {
        case daily = "Daily"
        case monthly = "30 Days"
        case quarterly = "120 Days"
    }
    
    struct Goal: Identifiable, Codable {
        let id: UUID
        let type: GoalType
        var title: String
        var description: String
        var isCompleted: Bool
        var targetDate: Date
        var progress: Double // 0.0 to 1.0
        
        init(id: UUID = UUID(),
             type: GoalType,
             title: String,
             description: String = "",
             isCompleted: Bool = false,
             targetDate: Date = Date(),
             progress: Double = 0.0) {
            self.id = id
            self.type = type
            self.title = title
            self.description = description
            self.isCompleted = isCompleted
            self.targetDate = targetDate
            self.progress = progress
        }
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func goalsForType(_ type: GoalType) -> [Goal] {
        goals.filter { $0.type == type }
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "goals")
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
    }
    
    init() {
        loadGoals()
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
    
    enum WaterUnit: String, CaseIterable {
        case liters = "Liters"
        case ounces = "Ounces"
        
        var suffix: String {
            switch self {
            case .liters: return "L"
            case .ounces: return "oz"
            }
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
    @StateObject private var expenseStore = ExpenseStore()
    @StateObject private var healthStore = HealthStore()
    @StateObject private var statusStore = StatusStore()
    @StateObject private var settingsStore = SettingsStore()
    @State private var selectedTab: Tab = .income
    @State private var isMenuOpen = false
    
    enum Tab: String, CaseIterable, Identifiable {
        case tasks
        case income
        case health
        case status
        case revision
        case goals
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
            case .settings: return "gearshape.fill"
            }
        }
    }
    
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
                    case .settings:
                        SettingsView()
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
                        settingsStore: settingsStore
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
    }

    
    private func setupAppearance(theme: AppTheme) {
        UINavigationBar.appearance().backgroundColor = UIColor(theme.backgroundColor)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(theme.textColor)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(theme.textColor)]
        UINavigationBar.appearance().tintColor = UIColor(theme.accentColor)
    }
}

// Side Menu View
struct SideMenuView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedTab: ContentView.Tab
    @Binding var isMenuOpen: Bool
    @ObservedObject var settingsStore: SettingsStore
    
    var body: some View {
        ZStack {
            settings.currentTheme.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            // Make the content scrollable
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                    
                    // Menu items - now scrollable if they don't fit
                    ForEach(ContentView.Tab.allCases) { tab in
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
                    
                    Spacer()
                    
                    // Theme selector
                    VStack(alignment: .leading) {
                        Text("THEME")
                            .font(.caption)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                            .padding(.horizontal, 20)
                        
                        Picker("Theme", selection: $settingsStore.currentTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue.capitalized)
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .colorMultiply(settings.currentTheme.primaryColor)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.leading, 20)
                .frame(width: UIScreen.main.bounds.width * 0.7)
            }
            .background(settings.currentTheme.backgroundColor)
        }
    }
}

// MARK: Tasks View
struct TaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @State private var showingAddTask = false
    @State private var showingEditTask = false
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var swipedTaskId: UUID? = nil
    @State private var taskToEdit: Task? = nil
    @State private var calendarViewMode: CalendarViewMode = .month // Add this state variable
    
    enum CalendarViewMode: String, CaseIterable {
        case month = "Month"
        case week = "Week"
        case day = "Day"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar View
                    CalendarTaskView(
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth,
                        taskStore: taskStore,
                        viewMode: $calendarViewMode // Pass the view mode
                    )
                    .padding(.horizontal)
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(settings.currentTheme.backgroundColor.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // View mode picker - Add this segment control
                    Picker("View Mode", selection: $calendarViewMode) {
                        ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Task List with iOS-style swipe to delete and edit
                    LazyVStack(spacing: 8) {
                        ForEach(filteredTasks) { task in
                            TaskRowWithActions(
                                task: task,
                                swipedTaskId: $swipedTaskId,
                                onDelete: {
                                    deleteTask(task)
                                },
                                onEdit: {
                                    taskToEdit = task
                                    showingEditTask = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskStore: taskStore, selectedDate: $selectedDate)
                    .environmentObject(settings)
            }
            .sheet(isPresented: $showingEditTask) {
                if let taskToEdit = taskToEdit {
                    EditTaskView(taskStore: taskStore, task: taskToEdit)
                        .environmentObject(settings)
                }
            }
        }
    }

    
    private var filteredTasks: [Task] {
        taskStore.tasksForDate(selectedDate)
            .sorted { $0.startDate < $1.startDate }
    }
    
    private func deleteTask(_ task: Task) {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation {
                taskStore.tasks.remove(at: index)
                taskStore.saveTasks()
            }
        }
    }
}


// iOS-style Swipe to Delete Row
struct iOSStyleSwipeToDeleteRow: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    @Binding var swipedTaskId: UUID?
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Delete button (hidden until swiped)
            if offset < 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut) {
                            offset = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDelete()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: deleteButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.move(edge: .trailing))
            }
            
            // Task content
            TaskRow(task: task)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if swipedTaskId == nil || swipedTaskId == task.id {
                                if gesture.translation.width < 0 {
                                    offset = gesture.translation.width
                                    swipedTaskId = task.id
                                }
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring()) {
                                if gesture.translation.width < -50 {
                                    offset = -deleteButtonWidth
                                    swipedTaskId = task.id
                                } else {
                                    offset = 0
                                    swipedTaskId = nil
                                }
                            }
                        }
                )
                .onChange(of: swipedTaskId) { newValue in
                    if newValue != task.id && offset != 0 {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        }
        .frame(height: 60)
        .contentShape(Rectangle())
    }
}

struct CalendarTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @ObservedObject var taskStore: TaskStore
    @Binding var viewMode: TaskView.CalendarViewMode // Add this
    
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Month header with navigation
            HStack {
                Text(currentMonth, formatter: monthFormatter)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        navigateMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                    
                    Button {
                        navigateMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            if viewMode != .day {
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(settings.currentTheme.textColor)
                    }
                }
            }
            
            // Dates grid - Updated to handle different view modes
            if viewMode == .month {
                monthView
            } else if viewMode == .week {
                weekView
            } else {
                dayView
            }
        }
    }
    
    private var monthView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInMonth(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: isSameDay(date, selectedDate),
                    hasTasks: taskStore.hasTasksOnDate(date),
                    isCurrentMonth: isSameMonth(date, currentMonth)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
    
    private var weekView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInWeek(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: isSameDay(date, selectedDate),
                    hasTasks: taskStore.hasTasksOnDate(date),
                    isCurrentMonth: isSameMonth(date, currentMonth)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
    
    private var dayView: some View {
        VStack {
            CalendarDayCell(
                date: selectedDate,
                isSelected: true,
                hasTasks: taskStore.hasTasksOnDate(selectedDate),
                isCurrentMonth: true
            )
            .frame(height: 60)
        }
    }
    
    private func navigateMonth(by months: Int) {
        if viewMode == .month || viewMode == .week {
            currentMonth = Calendar.current.date(byAdding: .month, value: months, to: currentMonth)!
        } else {
            selectedDate = Calendar.current.date(byAdding: .day, value: months > 0 ? 1 : -1, to: selectedDate)!
        }
    }
    
    private func daysInWeek() -> [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: selectedDate) else {
            return []
        }
        
        return Calendar.current.generateDates(
            for: DateInterval(start: weekInterval.start, end: weekInterval.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    private func CalendarDayCell(
        date: Date,
        isSelected: Bool,
        hasTasks: Bool,
        isCurrentMonth: Bool
    ) -> some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(settings.currentTheme.accentColor)
                    .frame(width: 30, height: 30)
            }
            
            Text(dayFormatter.string(from: date))
                .foregroundColor(
                    isSelected ? .white :
                    !isCurrentMonth ? settings.currentTheme.textColor.opacity(0.3) :
                    settings.currentTheme.textColor
                )
                .font(.system(size: 14))
            
            if hasTasks {
                Circle()
                    .fill(settings.currentTheme.primaryColor)
                    .frame(width: 5, height: 5)
                    .offset(y: 15)
            }
        }
        .frame(height: 40)
    }
    
    // Helper functions
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return Calendar.current.generateDates(
            for: dateInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .month)
    }
}

extension TaskStore {
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        let requestedDay = calendar.component(.day, from: date)
        let requestedMonth = calendar.component(.month, from: date)
        let requestedWeekday = calendar.component(.weekday, from: date)
        
        return tasks.filter { task in
            // Get components of the task's start date
            let taskDay = calendar.component(.day, from: task.startDate)
            let taskMonth = calendar.component(.month, from: task.startDate)
            let taskWeekday = calendar.component(.weekday, from: task.startDate)
            
            // Check if it's the exact date
            if calendar.isDate(task.startDate, inSameDayAs: date) {
                return true
            }
            
            // Check if this is a recurring task and the date is after the original task date
            guard let recurrence = task.recurrence, date > task.startDate else {
                return false
            }
            
            switch recurrence {
            case .daily:
                return true
            case .weekly:
                if let recurrenceDays = task.recurrenceDays {
                    return recurrenceDays.contains(requestedWeekday)
                } else {
                    // If no specific days set, use the original task's weekday
                    return requestedWeekday == taskWeekday
                }
            case .monthly:
                return requestedDay == taskDay
            case .yearly:
                return requestedDay == taskDay && requestedMonth == taskMonth
            case .none:
                return false
            }
        }
        .sorted {
            // First sort by start time
            if $0.startDate != $1.startDate {
                return $0.startDate < $1.startDate
            }
            // If start times are equal, sort by end time
            return $0.endDate < $1.endDate
        }
    }
    
    func hasTasksOnDate(_ date: Date) -> Bool {
        return !tasksForDate(date).isEmpty
    }
}

// TaskRow.swift
struct TaskRow: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time indicator
            VStack(alignment: .leading) {
                Text(task.startDate, style: .time)
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                if task.startDate != task.endDate {
                    Text(task.endDate, style: .time)
                        .font(.caption)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
            }
            .frame(width: 60)
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Color indicator
            Circle()
                .fill(Color(task.color.rawValue))
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(8)
    }
}

struct TaskRowWithActions: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    @Binding var swipedTaskId: UUID?
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 80
    private let editButtonWidth: CGFloat = 44
    
    var body: some View {
        ZStack {
            // Delete button (hidden until swiped)
            if offset < 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut) {
                            offset = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDelete()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: deleteButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.move(edge: .trailing))
            }
            
            // Task content with edit button
            HStack {
                TaskRow(task: task)
                
                // Edit button
                if offset == 0 {
                    Button(action: {
                        onEdit()
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                            .frame(width: editButtonWidth)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if swipedTaskId == nil || swipedTaskId == task.id {
                            offset = gesture.translation.width
                            swipedTaskId = task.id
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -50 {
                                offset = -deleteButtonWidth
                                swipedTaskId = task.id
                            } else if gesture.translation.width > 50 {
                                offset = 0
                                swipedTaskId = nil
                            } else {
                                offset = 0
                                swipedTaskId = nil
                            }
                        }
                    }
            )
            .onChange(of: swipedTaskId) { newValue in
                if newValue != task.id && offset != 0 {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }
            }
        }
        .frame(height: 60)
        .contentShape(Rectangle())
    }
}

struct EditTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @Environment(\.presentationMode) var presentationMode
    
    let task: Task
    @State private var editedTitle: String
    @State private var editedNotes: String
    @State private var editedColor: Task.TaskColor
    @State private var editedIsAllDay: Bool
    @State private var editedRecurrence: Task.Recurrence?
    @State private var editedRecurrenceDays: [Int]?
    
    // Date and time state
    @State private var startDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    
    init(taskStore: TaskStore, task: Task) {
        self.taskStore = taskStore
        self.task = task
        _editedTitle = State(initialValue: task.title)
        _editedNotes = State(initialValue: task.notes)
        _editedColor = State(initialValue: task.color)
        _editedIsAllDay = State(initialValue: Calendar.current.isDate(task.startDate, inSameDayAs: task.endDate))
        _editedRecurrence = State(initialValue: task.recurrence)
        _editedRecurrenceDays = State(initialValue: task.recurrenceDays)
        
        // Initialize date and time components
        let calendar = Calendar.current
        _startDate = State(initialValue: task.startDate)
        _startTime = State(initialValue: task.startDate)
        _endTime = State(initialValue: task.endDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                taskDetailsSection
                recurrenceSection
                saveButtonSection
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var taskDetailsSection: some View {
        Section(header: sectionHeader("Task Details")) {
            TextField("Title", text: $editedTitle)
            TextField("Notes (optional)", text: $editedNotes)
            
            Toggle("All-day", isOn: $editedIsAllDay)
            
            if !editedIsAllDay {
                DatePicker("Start Date",
                         selection: $startDate,
                         displayedComponents: .date)
                DatePicker("Start Time",
                         selection: $startTime,
                         displayedComponents: .hourAndMinute)
                DatePicker("End Time",
                         selection: $endTime,
                         in: startTime...,  // Ensures end time is after start time
                         displayedComponents: .hourAndMinute)
            }
            
            colorPicker
        }
    }
    
    private var colorPicker: some View {
        Picker("Color", selection: $editedColor) {
            ForEach(Task.TaskColor.allCases, id: \.self) { color in
                Text(color.rawValue.capitalized).tag(color)
            }
        }
    }
    
    private var recurrenceSection: some View {
        Section(header: sectionHeader("Recurrence")) {
            recurrencePicker
            if editedRecurrence == .weekly {
                weekdaySelection
            }
        }
    }
    
    private var recurrencePicker: some View {
        Picker("Repeat", selection: Binding<Task.Recurrence>(
            get: { editedRecurrence ?? Task.Recurrence.none },
            set: { newValue in
                editedRecurrence = (newValue == Task.Recurrence.none) ? nil : newValue
            }
        )) {
            ForEach(Task.Recurrence.allCases, id: \.self) { option in
                Text(option.rawValue.capitalized).tag(option)
            }
        }
        .pickerStyle(.menu)
    }
    
    private var weekdaySelection: some View {
        WeekdaySelectionView(selectedDays: Binding(
            get: { Set(editedRecurrenceDays?.compactMap { Weekday(rawValue: $0) } ?? []) },
            set: { editedRecurrenceDays = Array($0).map { $0.rawValue } }
        ))
    }
    
    private var saveButtonSection: some View {
        Section {
            Button("Save Changes") {
                saveChanges()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(settings.currentTheme.accentColor)
    }
    
    private func saveChanges() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            
            if editedIsAllDay {
                updatedTask.startDate = startDate.startOfDay
                updatedTask.endDate = startDate.endOfDay
            } else {
                // Combine date from startDate with time from pickers
                let calendar = Calendar.current
                let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                
                let newStartDate = calendar.date(
                    bySettingHour: startComponents.hour ?? 0,
                    minute: startComponents.minute ?? 0,
                    second: 0,
                    of: startDate
                ) ?? startDate
                
                var newEndDate = calendar.date(
                    bySettingHour: endComponents.hour ?? 0,
                    minute: endComponents.minute ?? 0,
                    second: 0,
                    of: startDate
                ) ?? startDate
                
                // Ensure end time is after start time
                if newEndDate <= newStartDate {
                    newEndDate = calendar.date(byAdding: .hour, value: 1, to: newStartDate) ?? newStartDate
                }
                
                updatedTask.startDate = newStartDate
                updatedTask.endDate = newEndDate
            }
            
            updatedTask.title = editedTitle
            updatedTask.notes = editedNotes
            updatedTask.color = editedColor
            updatedTask.recurrence = editedRecurrence
            updatedTask.recurrenceDays = editedRecurrenceDays
            
            taskStore.tasks[index] = updatedTask
            taskStore.saveTasks()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// AddTaskView.swift
struct AddTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var notes = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var color: Task.TaskColor = .blue
    @State private var isAllDay = false
    @State private var recurrenceOption: RecurrenceOption = .none
    @State private var selectedDays: Set<Weekday> = []
    
    enum RecurrenceOption: String, CaseIterable {
        case none = "Does not repeat"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").foregroundColor(settings.currentTheme.accentColor)) {
                    TextField("Title", text: $title)
                    TextField("Notes (optional)", text: $notes)
                    
                    Toggle("All-day", isOn: $isAllDay)
                    
                    if !isAllDay {
                        DatePicker("Start Time",
                                 selection: $startDate,
                                 displayedComponents: .hourAndMinute)
                        DatePicker("End Time",
                                 selection: $endDate,
                                 in: startDate...,
                                 displayedComponents: .hourAndMinute)
                    }
                    
                    Picker("Color", selection: $color) {
                        ForEach(Task.TaskColor.allCases, id: \.self) { color in
                            Text(color.rawValue.capitalized).tag(color)
                        }
                    }
                }
                
                Section(header: Text("Recurrence")) {
                    Picker("Repeat", selection: $recurrenceOption) {
                        ForEach(RecurrenceOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if recurrenceOption == .weekly {
                        WeekdaySelectionView(selectedDays: $selectedDays)
                    }
                }
                
                Section {
                    Button("Add Task") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                startDate = calendar.date(from: components) ?? Date()
                endDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? Date()
                
                // Preselect current day for weekly recurrence
                let weekday = calendar.component(.weekday, from: selectedDate)
                if let currentWeekday = Weekday(rawValue: weekday) {
                    selectedDays = [currentWeekday]
                }
            }
        }
    }
    
    private func addTask() {
        var recurrence: Task.Recurrence?
        var recurrenceDays: [Int]?
        
        switch recurrenceOption {
        case .none:
            recurrence = nil
            recurrenceDays = nil
        case .daily:
            recurrence = .daily
            recurrenceDays = nil
        case .weekly:
            recurrence = .weekly
            recurrenceDays = selectedDays.map { $0.rawValue }
        case .monthly:
            recurrence = .monthly
            recurrenceDays = nil
        case .yearly:
            recurrence = .yearly
            recurrenceDays = nil
        }
        
        let newTask = Task(
            title: title,
            notes: notes,
            startDate: isAllDay ? startDate.startOfDay : startDate,
            endDate: isAllDay ? startDate.endOfDay : endDate,
            color: color,
            recurrence: recurrence,
            recurrenceDays: recurrenceDays
        )
        
        taskStore.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

struct WeekdaySelectionView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedDays: Set<Weekday>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Repeat on:")
                .font(.subheadline)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            
            HStack {
                ForEach(Weekday.allCases) { day in
                    Button(action: {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }) {
                        Text(day.shortName)
                            .font(.caption)
                            .frame(width: 32, height: 32)
                            .background(selectedDays.contains(day) ?
                                        settings.currentTheme.accentColor :
                                        settings.currentTheme.backgroundColor.opacity(0.3))
                            .foregroundColor(selectedDays.contains(day) ?
                                            .white :
                                            settings.currentTheme.textColor)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
    }
}


// Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}

// MARK: - Income Views
struct IncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @ObservedObject var expenseStore: ExpenseStore
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var showingEditIncome = false
    @State private var incomeToEdit: IncomeRecord?
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary Cards
                        VStack(spacing: 16) {
                            
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
                            
                            // Income Cards
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Income Today",
                                    amount: incomeStore.todayTotal(),
                                    color: settings.currentTheme.accentColor
                                )
                                SummaryCard(
                                    title: "Income Week",
                                    amount: incomeStore.weeklyTotal(),
                                    color: settings.currentTheme.primaryColor
                                )
                                SummaryCard(
                                    title: "Income Month",
                                    amount: incomeStore.monthlyTotal(),
                                    color: settings.currentTheme.secondaryColor
                                )
                            }
                            
                            // Expense Cards
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Expenses Today",
                                    amount: expenseStore.todayTotal(),
                                    color: Color.red
                                )
                                SummaryCard(
                                    title: "Expenses Week",
                                    amount: expenseStore.weeklyTotal(),
                                    color: Color.orange
                                )
                                SummaryCard(
                                    title: "Expenses Month",
                                    amount: expenseStore.monthlyTotal(),
                                    color: Color.yellow
                                )
                            }
                            
                            // Net Cards
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Net Today",
                                    amount: incomeStore.todayTotal() - expenseStore.todayTotal(),
                                    color: incomeStore.todayTotal() - expenseStore.todayTotal() >= 0 ? Color.green : Color.red
                                )
                                SummaryCard(
                                    title: "Net Week",
                                    amount: incomeStore.weeklyTotal() - expenseStore.weeklyTotal(),
                                    color: incomeStore.weeklyTotal() - expenseStore.weeklyTotal() >= 0 ? Color.green : Color.red
                                )
                                SummaryCard(
                                    title: "Net Month",
                                    amount: incomeStore.monthlyTotal() - expenseStore.monthlyTotal(),
                                    color: incomeStore.monthlyTotal() - expenseStore.monthlyTotal() >= 0 ? Color.green : Color.red
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Add Expense Button
                        Button(action: {
                            showingAddExpense = true
                        }) {
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                Text("Add Expense")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Recent Transactions
                        VStack(spacing: 16) {
                            Text("Recent Transactions")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            // Recent Income
                            ForEach(incomeStore.records.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                TransactionRow(
                                    title: "Income",
                                    amount: record.amount,
                                    date: record.date,
                                    isIncome: true
                                )
                            }
                            
                            // Recent Expenses
                            ForEach(expenseStore.expenses.sorted(by: { $0.date > $1.date }).prefix(3)) { expense in
                                TransactionRow(
                                    title: expense.title,
                                    amount: -expense.amount,
                                    date: expense.date,
                                    isIncome: false,
                                    category: expense.category.rawValue
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Income & Expenses")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { showingAddIncome = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddIncome) {
                    AddIncomeView(incomeStore: incomeStore)
                }
                .sheet(isPresented: $showingAddExpense) {
                    AddExpenseView(expenseStore: expenseStore)
                }
                .sheet(isPresented: $showingEditIncome) {
                    if let incomeToEdit = incomeToEdit {
                        EditIncomeView(incomeStore: incomeStore, record: incomeToEdit)
                    }
                }
            }
        }
    }
}

struct AddExpenseView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var expenseStore: ExpenseStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var category = Expense.ExpenseCategory.other
    @State private var isRecurring = false
    @State private var recurrence: Expense.Recurrence?
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Expense Details").foregroundColor(settings.currentTheme.accentColor)) {
                        TextField("Title", text: $title)
                            .foregroundColor(settings.currentTheme.textColor)
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(settings.currentTheme.textColor)
                        
                        Picker("Category", selection: $category) {
                            ForEach(Expense.ExpenseCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .foregroundColor(settings.currentTheme.textColor)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section(header: Text("Recurrence").foregroundColor(settings.currentTheme.accentColor)) {
                        Toggle("Recurring Expense", isOn: $isRecurring)
                        
                        if isRecurring {
                            Picker("Recurrence", selection: $recurrence) {
                                ForEach(Expense.Recurrence.allCases, id: \.self) { recurrence in
                                    Text(recurrence.rawValue).tag(recurrence)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: addExpense) {
                            HStack {
                                Spacer()
                                Text("Add Expense")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                        .disabled(title.isEmpty || amount.isEmpty || (isRecurring && recurrence == nil))
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("New Expense")
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
    
    private func addExpense() {
        if let amountValue = Double(amount) {
            let expense = Expense(
                id: UUID(),
                title: title,
                amount: amountValue,
                date: date,
                category: category,
                isRecurring: isRecurring,
                recurrence: isRecurring ? recurrence : nil
            )
            expenseStore.addExpense(expense)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TransactionRow: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let amount: Double
    let date: Date
    let isIncome: Bool
    var category: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                if let category = category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
                
                Text(date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Spacer()
            
            Text(amount, format: .currency(code: "USD"))
                .font(.body.bold())
                .foregroundColor(isIncome ? Color.green : Color.red)
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(10)
    }
}

// New view for income row with swipe actions
struct IncomeRowWithActions: View {
    @EnvironmentObject var settings: SettingsStore
    let record: IncomeRecord
    @Binding var swipedIncomeId: UUID?
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 80
    private let editButtonWidth: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Delete button (hidden until swiped)
            if offset < 0 {
                HStack {
                    Spacer()
                    // Edit button
                    Button(action: {
                        withAnimation(.easeOut) {
                            offset = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onEdit()
                            }
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: editButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Delete button
                    Button(action: {
                        withAnimation(.easeOut) {
                            offset = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDelete()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: deleteButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.move(edge: .trailing))
            }
            
            // Income content
            IncomeRow(record: record)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if swipedIncomeId == nil || swipedIncomeId == record.id {
                                if gesture.translation.width < 0 {
                                    offset = gesture.translation.width
                                    swipedIncomeId = record.id
                                }
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring()) {
                                if gesture.translation.width < -50 {
                                    offset = -(deleteButtonWidth + editButtonWidth)
                                    swipedIncomeId = record.id
                                } else {
                                    offset = 0
                                    swipedIncomeId = nil
                                }
                            }
                        }
                )
                .onChange(of: swipedIncomeId) { newValue in
                    if newValue != record.id && offset != 0 {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        }
        .frame(height: 60)
        .contentShape(Rectangle())
    }
}

// New view for editing income
struct EditIncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @Environment(\.presentationMode) var presentationMode
    
    let record: IncomeRecord
    @State private var amount: String
    @State private var date: Date
    
    init(incomeStore: IncomeStore, record: IncomeRecord) {
        self.incomeStore = incomeStore
        self.record = record
        _amount = State(initialValue: String(format: "%.2f", record.amount))
        _date = State(initialValue: record.date)
    }
    
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
                        Button(action: saveChanges) {
                            HStack {
                                Spacer()
                                Text("Save Changes")
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
                .navigationTitle("Edit Income")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
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
    
    private func saveChanges() {
        if let amountValue = Double(amount) {
            incomeStore.updateRecord(record, withAmount: amountValue, newDate: date)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// Add these methods to your IncomeStore class
extension IncomeStore {
    func deleteRecord(_ record: IncomeRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records.remove(at: index)
            saveRecords()
        }
    }
    
    func updateRecord(_ record: IncomeRecord, withAmount amount: Double, newDate: Date) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index].amount = amount
            records[index].date = newDate
            saveRecords()
        }
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
    
    // States for individual metric editing
    @State private var showingEditWater = false
    @State private var showingEditSleep = false
    @State private var showingEditCalories = false
    @State private var tempWaterValue = ""
    @State private var tempSleepValue = ""
    @State private var tempCaloriesValue = ""
    
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
                                .healthMetricCardEditModifier(
                                    isPresented: $showingEditWater,
                                    title: "Water Intake",
                                    value: $tempWaterValue,
                                    healthStore: healthStore
                                )
                                .onAppear {
                                    tempWaterValue = String(format: "%.1f", healthStore.todaysRecord().waterIntake)
                                }
                                
                                HealthMetricCard(
                                    title: "Sleep",
                                    value: String(format: "%.1f hrs", healthStore.todaysRecord().sleepHours),
                                    goal: "8 hrs",
                                    progress: healthStore.todaysRecord().sleepHours / 8,
                                    color: .purple
                                )
                                .healthMetricCardEditModifier(
                                    isPresented: $showingEditSleep,
                                    title: "Sleep Hours",
                                    value: $tempSleepValue,
                                    healthStore: healthStore
                                )
                                .onAppear {
                                    tempSleepValue = String(format: "%.1f", healthStore.todaysRecord().sleepHours)
                                }
                            }
                            .padding(.horizontal)
                            
                            HealthMetricCard(
                                title: "Calories",
                                value: "\(healthStore.todaysRecord().caloriesConsumed)",
                                goal: "2000 kcal",
                                progress: Double(healthStore.todaysRecord().caloriesConsumed) / 2000,
                                color: .orange
                            )
                            .healthMetricCardEditModifier(
                                isPresented: $showingEditCalories,
                                title: "Calories Consumed",
                                value: $tempCaloriesValue,
                                healthStore: healthStore
                            )
                            .onAppear {
                                tempCaloriesValue = "\(healthStore.todaysRecord().caloriesConsumed)"
                            }
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

struct EditSingleHealthView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var healthStore: HealthStore
    let title: String
    @Binding var value: String
    var date: Date
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Edit \(title)").foregroundColor(settings.currentTheme.accentColor)) {
                        DatePicker("Date", selection: .constant(date), displayedComponents: .date)
                            .disabled(true) // Don't allow date change in this view
                        
                        HStack {
                            Image(systemName: iconForTitle(title))
                                .foregroundColor(colorForTitle(title))
                            TextField(title, text: $value)
                                .keyboardType(keyboardTypeForTitle(title))
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: saveChanges) {
                            HStack {
                                Spacer()
                                Text("Save Changes")
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
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Edit \(title)")
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
    
    private func iconForTitle(_ title: String) -> String {
        if title.contains("Water") { return "drop.fill" }
        if title.contains("Sleep") { return "moon.zzz.fill" }
        return "flame.fill"
    }
    
    private func colorForTitle(_ title: String) -> Color {
        if title.contains("Water") { return .blue }
        if title.contains("Sleep") { return .purple }
        return .orange
    }
    
    private func keyboardTypeForTitle(_ title: String) -> UIKeyboardType {
        if title.contains("Calories") { return .numberPad }
        return .decimalPad
    }
    
    private func saveChanges() {
        guard let newValue = Double(value) else { return }
        
        var record = healthStore.recordForDate(date) ?? HealthRecord(
            date: date,
            waterIntake: 0,
            sleepHours: 0,
            caloriesConsumed: 0
        )
        
        if title.contains("Water") {
            record.waterIntake = newValue
        } else if title.contains("Sleep") {
            record.sleepHours = newValue
        } else {
            record.caloriesConsumed = Int(newValue)
        }
        
        healthStore.updateRecord(record)
        presentationMode.wrappedValue.dismiss()
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

//MARK: - Revision View
struct RevisionView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var revisionStore = RevisionStore()
    @State private var showingAddRevision = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    let todaysRevision = revisionStore.getTodaysRevision()
                    
                    RevisionSection(title: "What Went Well", content: todaysRevision.whatWentWell)
                    RevisionSection(title: "What To Improve", content: todaysRevision.whatToImprove)
                    RevisionSection(title: "Lessons Learned", content: todaysRevision.lessonsLearned)
                    RevisionSection(title: "Tomorrow's Focus", content: todaysRevision.tomorrowFocus)
                    
                    Button(action: {
                        showingAddRevision = true
                    }) {
                        Text("Edit Today's Revision")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(settings.currentTheme.accentColor)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding(.top)
            }
            .navigationTitle("Daily Revision")
            .sheet(isPresented: $showingAddRevision) {
                AddRevisionView(revisionStore: revisionStore)
            }
        }
    }
}

struct RevisionSection: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            Text(content.isEmpty ? "Not answered yet" : content)
                .foregroundColor(content.isEmpty ? settings.currentTheme.textColor.opacity(0.5) : settings.currentTheme.textColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(settings.currentTheme.backgroundColor.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.horizontal)
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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("What Went Well").foregroundColor(settings.currentTheme.accentColor)) {
                    TextEditor(text: $whatWentWell)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("What To Improve").foregroundColor(settings.currentTheme.accentColor)) {
                    TextEditor(text: $whatToImprove)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Lessons Learned").foregroundColor(settings.currentTheme.accentColor)) {
                    TextEditor(text: $lessonsLearned)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Tomorrow's Focus").foregroundColor(settings.currentTheme.accentColor)) {
                    TextEditor(text: $tomorrowFocus)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("Save Revision") {
                        let revision = RevisionStore.DailyRevision(
                            whatWentWell: whatWentWell,
                            whatToImprove: whatToImprove,
                            lessonsLearned: lessonsLearned,
                            tomorrowFocus: tomorrowFocus
                        )
                        revisionStore.addRevision(revision)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(whatWentWell.isEmpty && whatToImprove.isEmpty && lessonsLearned.isEmpty && tomorrowFocus.isEmpty)
                }
            }
            .navigationTitle("Daily Revision")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                let todaysRevision = revisionStore.getTodaysRevision()
                whatWentWell = todaysRevision.whatWentWell
                whatToImprove = todaysRevision.whatToImprove
                lessonsLearned = todaysRevision.lessonsLearned
                tomorrowFocus = todaysRevision.tomorrowFocus
            }
        }
    }
}

//MARK: - Goals View
struct GoalsView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var goalsStore = GoalsStore()
    @State private var showingAddGoal = false
    @State private var selectedGoalType: GoalsStore.GoalType = .daily
    
    var body: some View {
        NavigationView {
            VStack {
                // Goal type selector
                Picker("Goal Type", selection: $selectedGoalType) {
                    ForEach(GoalsStore.GoalType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Goals list
                List {
                    ForEach(goalsStore.goalsForType(selectedGoalType)) { goal in
                        GoalRow(goal: goal)
                    }
                }
                .listStyle(.plain)
                
                Spacer()
            }
            .navigationTitle("My Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goalsStore: goalsStore, selectedType: selectedGoalType)
            }
        }
    }
}

struct GoalRow: View {
    @EnvironmentObject var settings: SettingsStore
    let goal: GoalsStore.Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if !goal.description.isEmpty {
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            ProgressView(value: goal.progress, total: 1.0)
                .accentColor(settings.currentTheme.accentColor)
            
            Text("Target: \(goal.targetDate, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

struct AddGoalView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var goalsStore: GoalsStore
    let selectedType: GoalsStore.GoalType
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()
    @State private var progress: Double = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details").foregroundColor(settings.currentTheme.accentColor)) {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description)
                    
                    DatePicker("Target Date",
                             selection: $targetDate,
                             in: Date()...,
                             displayedComponents: .date)
                }
                
                Section(header: Text("Progress").foregroundColor(settings.currentTheme.accentColor)) {
                    Slider(value: $progress, in: 0...1, step: 0.1)
                    Text("\(Int(progress * 100))% complete")
                        .foregroundColor(settings.currentTheme.textColor)
                }
                
                Section {
                    Button("Add Goal") {
                        let goal = GoalsStore.Goal(
                            type: selectedType,
                            title: title,
                            description: description,
                            isCompleted: progress >= 1.0,
                            targetDate: targetDate,
                            progress: progress
                        )
                        goalsStore.addGoal(goal)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("New \(selectedType.rawValue) Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
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

extension View {
    func healthMetricCardEditModifier(
        isPresented: Binding<Bool>,
        title: String,
        value: Binding<String>,
        healthStore: HealthStore,
        date: Date = Date()
    ) -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented.wrappedValue = true
            }
            .sheet(isPresented: isPresented) {
                EditSingleHealthView(
                    healthStore: healthStore,
                    title: title,
                    value: value,
                    date: date
                )
            }
    }
}

extension Double {
    func litersToOunces() -> Double {
        return self * 33.814
    }
    
    func ouncesToLiters() -> Double {
        return self / 33.814
    }
}
