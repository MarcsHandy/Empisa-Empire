import SwiftUI
import AVFoundation

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
struct HistoryCourse: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let durationInDays: Int
    var days: [HistoryDay]
    var isEnrolled: Bool
    var currentDay: Int
    var startDate: Date?
    var completedDays: [Int]
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         durationInDays: Int = 30,
         days: [HistoryDay] = [],
         isEnrolled: Bool = false,
         currentDay: Int = 0,
         startDate: Date? = nil,
         completedDays: [Int] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.durationInDays = durationInDays
        self.days = days
        self.isEnrolled = isEnrolled
        self.currentDay = currentDay
        self.startDate = startDate
        self.completedDays = completedDays
    }
}

struct HistoryDay: Identifiable, Codable {
    let id: UUID
    let dayNumber: Int
    let title: String
    let essay: String
    let keyPoints: [String]
    let reflectionQuestion: String
    let recommendedReading: String?
    let videoURL: String?
    
    init(id: UUID = UUID(),
         dayNumber: Int,
         title: String,
         essay: String,
         keyPoints: [String],
         reflectionQuestion: String,
         recommendedReading: String? = nil,
         videoURL: String? = nil) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.essay = essay
        self.keyPoints = keyPoints
        self.reflectionQuestion = reflectionQuestion
        self.recommendedReading = recommendedReading
        self.videoURL = videoURL
    }
}

struct HistoryReflection: Identifiable, Codable {
    let id: UUID
    let dayNumber: Int
    let date: Date
    let answer: String
    let notes: String
    
    init(id: UUID = UUID(),
         dayNumber: Int,
         date: Date = Date(),
         answer: String,
         notes: String = "") {
        self.id = id
        self.dayNumber = dayNumber
        self.date = date
        self.answer = answer
        self.notes = notes
    }
}

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
    var id = UUID()
    let date: Date
    var postsCreated: Int
    var storiesCreated: Int
    var reelsCreated: Int
    var commentsMade: Int
    var minutesEngaged: Int
    var outreachMessages: Int
}

// MARK: - ViewModels
class HistoryStore: ObservableObject {
    @Published var courses: [HistoryCourse] = []
    @Published var reflections: [HistoryReflection] = []
    @Published var speechSynthesizer = SpeechSynthesizer()
    
    init() {
        loadData()
        if courses.isEmpty {
            initializeSampleCourses()
        }
    }
    
    // MARK: - Course Management
    func enrollInCourse(courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            courses[index].isEnrolled = true
            courses[index].startDate = Date()
            courses[index].currentDay = 1
            saveData()
        }
    }
    
    func completeCurrentDay(courseId: UUID, reflectionAnswer: String, notes: String = "") {
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseId }),
              courses[courseIndex].isEnrolled,
              courses[courseIndex].currentDay <= courses[courseIndex].durationInDays else {
            return
        }
        
        let currentDay = courses[courseIndex].currentDay
        
        // Add reflection
        let reflection = HistoryReflection(
            dayNumber: currentDay,
            answer: reflectionAnswer,
            notes: notes
        )
        reflections.append(reflection)
        
        // Mark day as completed
        if !courses[courseIndex].completedDays.contains(currentDay) {
            courses[courseIndex].completedDays.append(currentDay)
        }
        
        // Move to next day if not at end
        if currentDay < courses[courseIndex].durationInDays {
            courses[courseIndex].currentDay += 1
        }
        
        saveData()
    }
    
    func getCurrentDayContent(courseId: UUID) -> HistoryDay? {
        guard let course = courses.first(where: { $0.id == courseId }),
              course.isEnrolled,
              course.currentDay <= course.durationInDays,
              let dayContent = course.days.first(where: { $0.dayNumber == course.currentDay }) else {
            return nil
        }
        return dayContent
    }
    
    // MARK: - Text-to-Speech
    func speak(text: String) {
        speechSynthesizer.speak(text: text)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking()
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        if let encodedCourses = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encodedCourses, forKey: "historyCourses")
        }
        if let encodedReflections = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(encodedReflections, forKey: "historyReflections")
        }
    }
    
    private func loadData() {
        if let coursesData = UserDefaults.standard.data(forKey: "historyCourses"),
           let decodedCourses = try? JSONDecoder().decode([HistoryCourse].self, from: coursesData) {
            courses = decodedCourses
        }
        if let reflectionsData = UserDefaults.standard.data(forKey: "historyReflections"),
           let decodedReflections = try? JSONDecoder().decode([HistoryReflection].self, from: reflectionsData) {
            reflections = decodedReflections
        }
    }
    
    // MARK: - Sample Data
    private func initializeSampleCourses() {
        // Create a 30-day African History course
        var africanHistoryDays: [HistoryDay] = []
        
        for day in 1...30 {
            africanHistoryDays.append(HistoryDay(
                dayNumber: day,
                title: "African History Day \(day)",
                essay: "This is a detailed essay about African history for day \(day). It covers important events, figures, and cultural aspects that shaped the continent. The content would be much more detailed in a real implementation, with proper historical research and citations.",
                keyPoints: [
                    "Key point 1 for day \(day)",
                    "Key point 2 for day \(day)",
                    "Key point 3 for day \(day)"
                ],
                reflectionQuestion: "What did you find most interesting about today's lesson?",
                recommendedReading: "Recommended book for day \(day)",
                videoURL: "https://example.com/video/day\(day)"
            ))
        }
        
        let africanHistoryCourse = HistoryCourse(
            title: "30 Days of African History",
            description: "A comprehensive journey through African history, covering ancient civilizations, colonialism, independence movements, and modern developments.",
            durationInDays: 30,
            days: africanHistoryDays
        )
        
        courses = [africanHistoryCourse]
        saveData()
    }
}

// Text-to-Speech Helper
class SpeechSynthesizer {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

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
    @Published var platforms: [Platform] = []
    @Published var dailyMetrics: [DailyMetric] = []
    
    init() {
        loadData()
        if platforms.isEmpty {
            // Initialize with common platforms if empty
            platforms = [
                Platform(name: "Instagram", icon: "camera"),
                Platform(name: "Twitter", icon: "bird"),
                Platform(name: "TikTok", icon: "music.note"),
                Platform(name: "YouTube", icon: "play.rectangle"),
                Platform(name: "LinkedIn", icon: "briefcase")
            ]
            saveData()
        }
    }
    
    // Platform management (permanent)
    func addPlatform(name: String, icon: String) {
        guard platforms.count < 5 else { return }
        let newPlatform = Platform(name: name, icon: icon)
        platforms.append(newPlatform)
        saveData()
    }
    
    // Daily metrics (reset each day)
    func incrementMetric(for platformId: UUID, metric: MetricType) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Find or create today's record
        if let index = dailyMetrics.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyMetrics[index].increment(metric: metric, platformId: platformId)
        } else {
            var newMetric = DailyMetric(date: today)
            newMetric.increment(metric: metric, platformId: platformId)
            dailyMetrics.append(newMetric)
        }
        
        saveData()
    }
    
    func getTodayMetrics() -> DailyMetric {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyMetrics.first { Calendar.current.isDate($0.date, inSameDayAs: today) } ?? DailyMetric(date: today)
    }
    
    // Data persistence
    private func saveData() {
        let encoder = JSONEncoder()
        if let encodedPlatforms = try? encoder.encode(platforms),
           let encodedMetrics = try? encoder.encode(dailyMetrics) {
            UserDefaults.standard.set(encodedPlatforms, forKey: "platforms")
            UserDefaults.standard.set(encodedMetrics, forKey: "dailyMetrics")
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        if let platformsData = UserDefaults.standard.data(forKey: "platforms"),
           let decodedPlatforms = try? decoder.decode([Platform].self, from: platformsData) {
            platforms = decodedPlatforms
        }
        if let metricsData = UserDefaults.standard.data(forKey: "dailyMetrics"),
           let decodedMetrics = try? decoder.decode([DailyMetric].self, from: metricsData) {
            dailyMetrics = decodedMetrics
        }
    }
}

struct Platform: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let icon: String
}

struct DailyMetric: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var posts: [UUID: Int] = [:] // Platform ID: Count
    var comments: [UUID: Int] = [:] // Platform ID: Count
    var minutes: [UUID: Int] = [:] // Platform ID: Count
    
    mutating func increment(metric: MetricType, platformId: UUID) {
        switch metric {
        case .post:
            posts[platformId] = (posts[platformId] ?? 0) + 1
        case .comment:
            comments[platformId] = (comments[platformId] ?? 0) + 1
        case .minute:
            minutes[platformId] = (minutes[platformId] ?? 0) + 1
        }
    }
    
    func count(for metric: MetricType, platformId: UUID) -> Int {
        switch metric {
        case .post: return posts[platformId] ?? 0
        case .comment: return comments[platformId] ?? 0
        case .minute: return minutes[platformId] ?? 0
        }
    }
}

enum MetricType {
    case post, comment, minute
}

class RevisionStore: ObservableObject {
    @Published var dailyRevisions: [DailyRevision] = []
    @Published var weeklyRetrospectives: [WeeklyRetrospective] = []
    
    struct DailyRevision: Identifiable, Codable {
        let id: UUID
        let date: Date
        var whatWentWell: String
        var whatToImprove: String
        var lessonsLearned: String
        var tomorrowFocus: String
        var energyLevel: Int // 1-5 scale
        var mood: Mood
        var keyAchievements: [String]
        var gratitudeList: [String]
        
        enum Mood: String, CaseIterable, Codable {
            case terrible = "😞"
            case bad = "🙁"
            case neutral = "😐"
            case good = "🙂"
            case great = "😄"
            
            var description: String {
                switch self {
                case .terrible: return "Terrible"
                case .bad: return "Bad"
                case .neutral: return "Neutral"
                case .good: return "Good"
                case .great: return "Great"
                }
            }
        }
        
        init(id: UUID = UUID(),
             date: Date = Date(),
             whatWentWell: String = "",
             whatToImprove: String = "",
             lessonsLearned: String = "",
             tomorrowFocus: String = "",
             energyLevel: Int = 3,
             mood: Mood = .neutral,
             keyAchievements: [String] = [],
             gratitudeList: [String] = []) {
            self.id = id
            self.date = date
            self.whatWentWell = whatWentWell
            self.whatToImprove = whatToImprove
            self.lessonsLearned = lessonsLearned
            self.tomorrowFocus = tomorrowFocus
            self.energyLevel = energyLevel
            self.mood = mood
            self.keyAchievements = keyAchievements
            self.gratitudeList = gratitudeList
        }
    }
    
    struct WeeklyRetrospective: Identifiable, Codable {
        let id: UUID
        let startDate: Date
        let endDate: Date
        var weeklyWins: [String]
        var biggestChallenges: [String]
        var keyLearnings: [String]
        var improvementPlan: [String]
        var rating: Int // 1-10 scale
        
        init(id: UUID = UUID(),
             startDate: Date = Date().startOfWeek,
             endDate: Date = Date().endOfWeek,
             weeklyWins: [String] = [],
             biggestChallenges: [String] = [],
             keyLearnings: [String] = [],
             improvementPlan: [String] = [],
             rating: Int = 5) {
            self.id = id
            self.startDate = startDate
            self.endDate = endDate
            self.weeklyWins = weeklyWins
            self.biggestChallenges = biggestChallenges
            self.keyLearnings = keyLearnings
            self.improvementPlan = improvementPlan
            self.rating = rating
        }
    }
    
    // MARK: - Daily Revision Methods
    func addRevision(_ revision: DailyRevision) {
        if let index = dailyRevisions.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: revision.date) }) {
            dailyRevisions[index] = revision
        } else {
            dailyRevisions.append(revision)
        }
        saveRevisions()
        
        // Check if we should create a weekly retrospective
        if shouldCreateWeeklyRetrospective() {
            createWeeklyRetrospective()
        }
    }
    
    func getTodaysRevision() -> DailyRevision {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyRevisions.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) ??
               DailyRevision(date: today)
    }
    
    func getRevisionsForWeek(containing date: Date) -> [DailyRevision] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        
        return dailyRevisions.filter {
            calendar.isDate($0.date, inSameDayAs: weekInterval.start) ||
            ($0.date > weekInterval.start && $0.date < weekInterval.end)
        }
    }
    
    // MARK: - Weekly Retrospective Methods
    private func shouldCreateWeeklyRetrospective() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if today is Sunday (end of week)
        let isEndOfWeek = calendar.component(.weekday, from: today) == 1 // 1 = Sunday
        
        // Check if we already have a retrospective for this week
        let hasRetrospective = weeklyRetrospectives.contains { retrospective in
            calendar.isDate(today, equalTo: retrospective.endDate, toGranularity: .day)
        }
        
        // Check if we have at least 3 days of data
        let daysThisWeek = getRevisionsForWeek(containing: today).count
        
        return isEndOfWeek && !hasRetrospective && daysThisWeek >= 3
    }
    
    private func createWeeklyRetrospective() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = today.startOfWeek
        let endOfWeek = today.endOfWeek
        
        let weekRevisions = getRevisionsForWeek(containing: today)
        
        // Aggregate data from daily revisions
        var weeklyWins: [String] = []
        var challenges: [String] = []
        var learnings: [String] = []
        
        for revision in weekRevisions {
            weeklyWins.append(contentsOf: revision.keyAchievements)
            challenges.append(revision.whatToImprove)
            learnings.append(revision.lessonsLearned)
        }
        
        // Calculate average rating
        let averageRating = weekRevisions.isEmpty ? 5 :
            (weekRevisions.reduce(0) { $0 + $1.energyLevel } / weekRevisions.count)
        
        let retrospective = WeeklyRetrospective(
            startDate: startOfWeek,
            endDate: endOfWeek,
            weeklyWins: weeklyWins,
            biggestChallenges: Array(Set(challenges)), // Remove duplicates
            keyLearnings: Array(Set(learnings)), // Remove duplicates
            rating: averageRating
        )
        
        weeklyRetrospectives.append(retrospective)
        saveWeeklyRetrospectives()
    }
    
    // MARK: - Data Persistence
    private func saveRevisions() {
        if let encoded = try? JSONEncoder().encode(dailyRevisions) {
            UserDefaults.standard.set(encoded, forKey: "dailyRevisions")
        }
    }
    
    private func saveWeeklyRetrospectives() {
        if let encoded = try? JSONEncoder().encode(weeklyRetrospectives) {
            UserDefaults.standard.set(encoded, forKey: "weeklyRetrospectives")
        }
    }
    
    private func loadRevisions() {
        if let data = UserDefaults.standard.data(forKey: "dailyRevisions"),
           let decoded = try? JSONDecoder().decode([DailyRevision].self, from: data) {
            dailyRevisions = decoded
        }
    }
    
    private func loadWeeklyRetrospectives() {
        if let data = UserDefaults.standard.data(forKey: "weeklyRetrospectives"),
           let decoded = try? JSONDecoder().decode([WeeklyRetrospective].self, from: data) {
            weeklyRetrospectives = decoded
        }
    }
    
    init() {
        loadRevisions()
        loadWeeklyRetrospectives()
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
    
    @Published var waterUnit: WaterUnit {
        didSet {
            UserDefaults.standard.set(waterUnit.rawValue, forKey: "waterUnitPreference")
        }
    }
    enum WaterUnit: String, CaseIterable {
        case liters = "L"
        case ounces = "oz"
        
        var conversionFactor: Double {
            switch self {
            case .liters: return 1.0
            case .ounces: return 33.814
            }
        }
    }
    
    init() {
        // First load the water unit preference
        let savedUnit = UserDefaults.standard.string(forKey: "waterUnitPreference")
        self.waterUnit = WaterUnit(rawValue: savedUnit ?? "L") ?? .liters
        
        // Then load other settings
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
                        isMenuOpen: $isMenuOpen
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
                    
                    Text("History Coming Soon")
                        .font(.subheadline)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .background(settings.currentTheme.textColor.opacity(0.2))
                        .padding(.vertical, 8)
                    
                    // Present / Philosophy / Mind Section
                    SectionHeader(title: "Present / Philosophy / Mind")
                    
                    ForEach(ContentView.Tab.allCases.filter { tab in
                        tab != .settings && tab != .goals
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
// MARK: History View
struct HistoryView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var historyStore = HistoryStore()
    @State private var showingCourseDetail = false
    @State private var selectedCourse: HistoryCourse?
    @State private var showingReflectionSheet = false
    @State private var reflectionAnswer = ""
    @State private var reflectionNotes = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Course Progress
                    if let currentCourse = historyStore.courses.first(where: { $0.isEnrolled }) {
                        currentCourseView(course: currentCourse)
                    }
                    
                    // Available Courses
                    availableCoursesSection
                }
                .padding()
            }
            .navigationTitle("History Learning")
            .sheet(isPresented: $showingCourseDetail) {
                if let course = selectedCourse {
                    CourseDetailView(historyStore: historyStore, course: course)
                        .environmentObject(settings)
                }
            }
            .sheet(isPresented: $showingReflectionSheet) {
                if let currentCourse = historyStore.courses.first(where: { $0.isEnrolled }) {
                    ReflectionView(
                        question: currentCourse.days.first { $0.dayNumber == currentCourse.currentDay }?.reflectionQuestion ?? "",
                        answer: $reflectionAnswer,
                        notes: $reflectionNotes,
                        onSubmit: {
                            historyStore.completeCurrentDay(
                                courseId: currentCourse.id,
                                reflectionAnswer: reflectionAnswer,
                                notes: reflectionNotes
                            )
                            reflectionAnswer = ""
                            reflectionNotes = ""
                            showingReflectionSheet = false
                        }
                    )
                    .environmentObject(settings)
                }
            }
        }
    }
    
    private func currentCourseView(course: HistoryCourse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Course")
                    .font(.title2.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text("Day \(course.currentDay) of \(course.durationInDays)")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Text(course.title)
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            ProgressView(value: Double(course.currentDay), total: Double(course.durationInDays))
                .tint(settings.currentTheme.accentColor)
            
            if let dayContent = historyStore.getCurrentDayContent(courseId: course.id) {
                NavigationLink {
                    DayContentView(
                        historyStore: historyStore, day: dayContent,
                        onComplete: {
                            showingReflectionSheet = true
                        }
                    )
                    .environmentObject(settings)
                } label: {
                    Text("Continue to Day \(dayContent.dayNumber): \(dayContent.title)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(settings.currentTheme.accentColor)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var availableCoursesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Courses")
                .font(.title2.bold())
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(historyStore.courses.filter { !$0.isEnrolled }) { course in
                CourseCard(course: course)
                    .onTapGesture {
                        selectedCourse = course
                        showingCourseDetail = true
                    }
            }
        }
    }
}

struct CourseCard: View {
    @EnvironmentObject var settings: SettingsStore
    let course: HistoryCourse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(settings.currentTheme.accentColor)
                Text(course.title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text("\(course.durationInDays) days")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.8))
                .lineLimit(2)
            
            HStack {
                Spacer()
                Text("Tap to learn more")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.accentColor)
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(settings.currentTheme.backgroundColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CourseDetailView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var historyStore: HistoryStore
    let course: HistoryCourse
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(course.title)
                        .font(.title.bold())
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Text(course.description)
                        .font(.body)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Course Details")
                            .font(.headline)
                            .foregroundColor(settings.currentTheme.textColor)
                        
                        DetailRow(icon: "calendar", text: "\(course.durationInDays) days")
                        DetailRow(icon: "book", text: "Daily essays and readings")
                        DetailRow(icon: "questionmark.circle", text: "Reflection questions")
                        DetailRow(icon: "checkmark.circle", text: "Track your progress")
                    }
                    .padding()
                    .background(settings.currentTheme.backgroundColor.opacity(0.1))
                    .cornerRadius(10)
                    
                    if !course.isEnrolled {
                        Button(action: {
                            historyStore.enrollInCourse(courseId: course.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Enroll in Course")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(settings.currentTheme.accentColor)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Course Details", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(settings.currentTheme.accentColor)
                }
            }
        }
    }
}

struct DetailRow: View {
    @EnvironmentObject var settings: SettingsStore
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(settings.currentTheme.accentColor)
                .frame(width: 30)
            Text(text)
                .foregroundColor(settings.currentTheme.textColor)
            Spacer()
        }
    }
}

struct DayContentView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var historyStore: HistoryStore
    let day: HistoryDay
    let onComplete: () -> Void
    
    @State private var isSpeaking = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Day \(day.dayNumber)")
                        .font(.title.bold())
                        .foregroundColor(settings.currentTheme.textColor)
                    Spacer()
                    
                    Button(action: toggleSpeech) {
                        Image(systemName: isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
                
                Text(day.title)
                    .font(.title2)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Divider()
                
                Text("Today's Essay")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Text(day.essay)
                    .font(.body)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Divider()
                
                Text("Key Points")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                ForEach(day.keyPoints, id: \.self) { point in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(settings.currentTheme.accentColor)
                            .padding(.top, 6)
                        Text(point)
                            .font(.body)
                            .foregroundColor(settings.currentTheme.textColor)
                    }
                }
                
                if let reading = day.recommendedReading {
                    Divider()
                    
                    Text("Recommended Reading")
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Text(reading)
                        .font(.body)
                        .foregroundColor(settings.currentTheme.textColor)
                }
                
                if let videoURL = day.videoURL, let url = URL(string: videoURL) {
                    Divider()
                    
                    Text("Supplementary Video")
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Watch Video")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                }
                
                Button(action: onComplete) {
                    Text("Complete Day")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(settings.currentTheme.accentColor)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationBarTitle("Day \(day.dayNumber)", displayMode: .inline)
        .onAppear {
            historyStore.stopSpeaking()
            isSpeaking = false
        }
        .onDisappear {
            historyStore.stopSpeaking()
        }
    }
    
    private func toggleSpeech() {
        if isSpeaking {
            historyStore.stopSpeaking()
        } else {
            historyStore.speak(text: "\(day.title). \(day.essay)")
        }
        isSpeaking.toggle()
    }
}

struct ReflectionView: View {
    @EnvironmentObject var settings: SettingsStore
    let question: String
    @Binding var answer: String
    @Binding var notes: String
    let onSubmit: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reflection Question").foregroundColor(settings.currentTheme.accentColor)) {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    TextField("Your answer", text: $answer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Additional Notes").foregroundColor(settings.currentTheme.accentColor)) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(settings.currentTheme.backgroundColor.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Section {
                    Button(action: onSubmit) {
                        HStack {
                            Spacer()
                            Text("Submit Reflection")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(answer.isEmpty)
                    .tint(settings.currentTheme.accentColor)
                }
            }
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onSubmit() // Still submit but with empty values if user cancels
                    }
                }
            }
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
        _ = Calendar.current
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
    @State private var showingUnitSettings = false
    
    // States for individual metric editing
    @State private var showingEditWater = false
    @State private var showingEditSleep = false
    @State private var showingEditCalories = false
    @State private var tempWaterValue = ""
    @State private var tempSleepValue = ""
    @State private var tempCaloriesValue = ""
    
    private var todaysRecord: HealthRecord {
        healthStore.todaysRecord()
    }
    
    private var weeklyAverages: (water: Double, sleep: Double, calories: Int) {
        healthStore.weeklyAverage()
    }
    
    // Computed properties for water display
    private var waterDisplayValue: String {
        String(format: "%.1f %@", todaysRecord.waterIntake.converted(to: settings.waterUnit), settings.waterUnit.rawValue)
    }
    
    private var waterDisplayGoal: String {
        let baseGoal = 2.5 // 2.5 liters is the base goal
        let convertedGoal = baseGoal * settings.waterUnit.conversionFactor
        return String(format: "%.1f %@", convertedGoal, settings.waterUnit.rawValue)
    }
    
    private var waterProgress: Double {
        let baseGoal = 2.5
        return todaysRecord.waterIntake / baseGoal
    }
    
    private var avgWaterDisplayValue: String {
        String(format: "%.1f %@", weeklyAverages.water.converted(to: settings.waterUnit), settings.waterUnit.rawValue)
    }
        
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Summary
                        VStack(spacing: 16) {
                            HStack {
                                Text("Today's Health")
                                    .font(.title2.bold())
                                    .foregroundColor(settings.currentTheme.textColor)
                                
                                Spacer()
                                
                                Button(action: { showingUnitSettings = true }) {
                                    Image(systemName: "gear")
                                        .foregroundColor(settings.currentTheme.accentColor)
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                HealthMetricCard(
                                    title: "Water",
                                    value: waterDisplayValue,
                                    goal: waterDisplayGoal,
                                    progress: waterProgress,
                                    color: .blue
                                )
                                
                                HealthMetricCard(
                                    title: "Sleep",
                                    value: String(format: "%.1f hrs", todaysRecord.sleepHours),
                                    goal: "8 hrs",
                                    progress: todaysRecord.sleepHours / 8,
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
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
                                    value: avgWaterDisplayValue,
                                    goal: waterDisplayGoal,
                                    progress: weeklyAverages.water / 2.5,
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
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Health Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddHealth = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddHealth) {
                    AddHealthView(healthStore: healthStore)
                }
                .sheet(isPresented: $showingUnitSettings) {
                    WaterUnitSettingsView()
                }
            }
        }
    }


struct WaterUnitSettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Water Measurement Unit")) {
                    Picker("Unit", selection: $settings.waterUnit) {
                        ForEach(SettingsStore.WaterUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Units")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
    
    private var waterDisplayValue: String {
        String(format: "%.1f %@",
              record.waterIntake.converted(to: settings.waterUnit),
              settings.waterUnit.rawValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.date, format: .dateTime.day().month().year())
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            HStack {
                HealthMetricPill(
                    value: waterDisplayValue,
                    label: "Water",
                    color: .blue
                )
                HealthMetricPill(
                    value: String(format: "%.1f hrs", record.sleepHours),
                    label: "Sleep",
                    color: .purple
                )
                HealthMetricPill(
                    value: "\(record.caloriesConsumed)",
                    label: "Calories",
                    color: .orange
                )
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
                            TextField("Water (\(settings.waterUnit.rawValue))", text: $waterIntake)
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

//MARK: Status View
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

//MARK: - Revision View
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

//MARK: - Goals View
struct GoalsView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var goalsStore = GoalsStore()
    @State private var showingAddGoal = false
    @State private var selectedGoalType: GoalsStore.GoalType = .daily
    @State private var searchText = ""
    @State private var showingCompleted = true
    @State private var editingGoal: GoalsStore.Goal? = nil

    var filteredGoals: [GoalsStore.Goal] {
        var goals = goalsStore.goalsForType(selectedGoalType)
        
        if !searchText.isEmpty {
            goals = goals.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if !showingCompleted {
            goals = goals.filter { !$0.isCompleted }
        }
        
        return goals.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            return $0.targetDate < $1.targetDate
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText, placeholder: "Search goals")
                    
                    HStack {
                        Picker("Goal Type", selection: $selectedGoalType) {
                            ForEach(GoalsStore.GoalType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Button(action: { showingCompleted.toggle() }) {
                            Image(systemName: showingCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundColor(showingCompleted ? settings.currentTheme.accentColor : settings.currentTheme.textColor)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                .background(settings.currentTheme.backgroundColor.opacity(0.8))
                
                // Goals list
                if filteredGoals.isEmpty {
                    EmptyGoalsView(goalType: selectedGoalType)
                } else {
                    List {
                        ForEach(filteredGoals) { goal in
                            GoalCard(goal: goal)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        goalsStore.deleteGoal(goal)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingGoal = goal
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    
                                    Button {
                                        goalsStore.toggleGoalCompletion(goal)
                                    } label: {
                                        Label(goal.isCompleted ? "Mark Incomplete" : "Complete",
                                              systemImage: goal.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                    }
                                    .tint(goal.isCompleted ? .orange : .green)
                                }
                                .onTapGesture {
                                    editingGoal = goal
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddEditGoalView(goalsStore: goalsStore, goal: nil, selectedType: selectedGoalType)
            }
            .sheet(item: $editingGoal) { goal in
                AddEditGoalView(goalsStore: goalsStore, goal: goal, selectedType: goal.type)
            }
        }
    }
}

struct AddEditGoalView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var goalsStore: GoalsStore
    var goal: GoalsStore.Goal?
    let selectedType: GoalsStore.GoalType
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var description: String
    @State private var targetDate: Date
    @State private var progress: Double
    @State private var showingDatePicker = false
    
    init(goalsStore: GoalsStore, goal: GoalsStore.Goal?, selectedType: GoalsStore.GoalType) {
        self.goalsStore = goalsStore
        self.goal = goal
        self.selectedType = selectedType
        
        if let existingGoal = goal {
            _title = State(initialValue: existingGoal.title)
            _description = State(initialValue: existingGoal.description)
            _targetDate = State(initialValue: existingGoal.targetDate)
            _progress = State(initialValue: existingGoal.progress)
        } else {
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            
            // Set default target date based on goal type
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            
            switch selectedType {
            case .daily:
                dateComponents.day = 1
            case .monthly:
                dateComponents.month = 1
            case .quarterly:
                dateComponents.month = 3
            }
            
            _targetDate = State(initialValue: calendar.date(byAdding: dateComponents, to: Date()) ?? Date())
            _progress = State(initialValue: 0)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Goal title", text: $title)
                        .font(.headline)
                    
                    TextField("Description (optional)", text: $description)
                }
                
                Section {
                    HStack {
                        Text("Goal Type")
                        Spacer()
                        Text(selectedType.rawValue)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    }
                    
                    HStack {
                        Text("Target Date")
                        Spacer()
                        Button(action: { showingDatePicker.toggle() }) {
                            Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(settings.currentTheme.textColor)
                        }
                    }
                    
                    if showingDatePicker {
                        DatePicker(
                            "Select target date",
                            selection: $targetDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Progress: \(Int(progress * 100))%")
                            .font(.subheadline)
                        
                        Slider(value: $progress, in: 0...1, step: 0.05)
                            .tint(progress >= 1 ? .green : settings.currentTheme.accentColor)
                        
                        HStack {
                            ForEach([0, 0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                                Button(action: { progress = value }) {
                                    Text("\(Int(value * 100))%")
                                        .font(.caption)
                                        .padding(4)
                                        .frame(minWidth: 30)
                                        .background(progress == value ? settings.currentTheme.accentColor.opacity(0.3) : Color.clear)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: saveGoal) {
                        HStack {
                            Spacer()
                            Text(goal == nil ? "Add Goal" : "Save Changes")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                    .tint(settings.currentTheme.accentColor)
                }
                
                if goal != nil {
                    Section {
                        Button(role: .destructive) {
                            if let goal = goal {
                                goalsStore.deleteGoal(goal)
                            }
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Goal")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(goal == nil ? "New \(selectedType.rawValue) Goal" : "Edit Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveGoal() {
        let updatedGoal = GoalsStore.Goal(
            id: goal?.id ?? UUID(),
            type: selectedType,
            title: title,
            description: description,
            isCompleted: progress >= 1.0,
            targetDate: targetDate,
            progress: progress
        )
        
        if goal != nil {
            goalsStore.updateGoal(updatedGoal)
        } else {
            goalsStore.addGoal(updatedGoal)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct GoalCard: View {
    @EnvironmentObject var settings: SettingsStore
    let goal: GoalsStore.Goal
    
    private var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0
    }
    
    private var progressColor: Color {
        if goal.progress >= 1.0 {
            return .green
        } else if daysRemaining <= 0 {
            return .red
        } else {
            return settings.currentTheme.accentColor
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                        .strikethrough(goal.isCompleted)
                    
                    if !goal.description.isEmpty {
                        Text(goal.description)
                            .font(.subheadline)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                            .strikethrough(goal.isCompleted)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else {
                        Text("\(daysRemaining > 0 ? daysRemaining : 0)d")
                            .font(.caption)
                            .foregroundColor(daysRemaining <= 0 ? .red : settings.currentTheme.textColor.opacity(0.7))
                            .padding(6)
                            .background(Circle().fill(daysRemaining <= 0 ? Color.red.opacity(0.2) : settings.currentTheme.backgroundColor.opacity(0.3)))
                    }
                    
                    Text(goal.targetDate, formatter: dateFormatter)
                        .font(.caption2)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                }
            }
            
            ProgressView(value: goal.progress, total: 1.0)
                .tint(progressColor)
            
            HStack {
                Text("\(Int(goal.progress * 100))% complete")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                
                Spacer()
                
                Text(goal.type.rawValue)
                    .font(.caption)
                    .padding(4)
                    .padding(.horizontal, 4)
                    .background(Capsule().fill(settings.currentTheme.backgroundColor.opacity(0.3)))
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(settings.currentTheme.backgroundColor.opacity(0.3), lineWidth: 1)
        )
        .opacity(goal.isCompleted ? 0.8 : 1.0)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct EmptyGoalsView: View {
    @EnvironmentObject var settings: SettingsStore
    let goalType: GoalsStore.GoalType
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(settings.currentTheme.textColor.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No \(goalType.rawValue.lowercased()) goals yet")
                    .font(.title3)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Text("Add your first \(goalType.rawValue.lowercased()) goal to get started")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddGoalView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var goalsStore: GoalsStore
    let selectedType: GoalsStore.GoalType
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetDate: Date
    @State private var progress: Double = 0
    @State private var showingDatePicker = false
    
    init(goalsStore: GoalsStore, selectedType: GoalsStore.GoalType) {
        self.goalsStore = goalsStore
        self.selectedType = selectedType
        
        // Set default target date based on goal type
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch selectedType {
        case .daily:
            dateComponents.day = 1
        case .monthly:
            dateComponents.month = 1
        case .quarterly:
            dateComponents.month = 3
        }
        
        _targetDate = State(initialValue: calendar.date(byAdding: dateComponents, to: Date()) ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Goal title", text: $title)
                        .font(.headline)
                    
                    TextField("Description (optional)", text: $description)
                }
                
                Section {
                    HStack {
                        Text("Target Date")
                        Spacer()
                        Button(action: { showingDatePicker.toggle() }) {
                            Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(settings.currentTheme.textColor)
                        }
                    }
                    
                    if showingDatePicker {
                        DatePicker(
                            "Select target date",
                            selection: $targetDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Progress: \(Int(progress * 100))%")
                            .font(.subheadline)
                        
                        Slider(value: $progress, in: 0...1, step: 0.05)
                            .tint(progress >= 1 ? .green : settings.currentTheme.accentColor)
                        
                        HStack {
                            ForEach([0, 0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                                Button(action: { progress = value }) {
                                    Text("\(Int(value * 100))%")
                                        .font(.caption)
                                        .padding(4)
                                        .frame(minWidth: 30)
                                        .background(progress == value ? settings.currentTheme.accentColor.opacity(0.3) : Color.clear)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: addGoal) {
                        HStack {
                            Spacer()
                            Text("Add Goal")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                    .tint(settings.currentTheme.accentColor)
                }
            }
            .navigationTitle("New \(selectedType.rawValue) Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addGoal() {
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
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
    }
}

// MARK: - Settings View
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

// MARK: - Helper Extensions
extension SettingsStore {
    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "notificationsEnabled") }
    }
    
    var dailyReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "dailyReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "dailyReminders") }
    }
    
    var dailyReminderTime: Date {
        get {
            UserDefaults.standard.object(forKey: "dailyReminderTime") as? Date ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
        set { UserDefaults.standard.set(newValue, forKey: "dailyReminderTime") }
    }
    
    var taskReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "taskReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "taskReminders") }
    }
    
    var goalReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "goalReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "goalReminders") }
    }
    
    var healthReminders: Bool {
        get { UserDefaults.standard.bool(forKey: "healthReminders") }
        set { UserDefaults.standard.set(newValue, forKey: "healthReminders") }
    }
    
    func exportAllData() {
        // Implementation for exporting data
        print("Exporting all data...")
    }
    
    func importData() {
        // Implementation for importing data
        print("Importing data...")
    }
    
    func resetSettings() {
        UserDefaults.standard.removeObject(forKey: "appTheme")
        UserDefaults.standard.removeObject(forKey: "waterUnitPreference")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "dailyReminders")
        UserDefaults.standard.removeObject(forKey: "dailyReminderTime")
        UserDefaults.standard.removeObject(forKey: "taskReminders")
        UserDefaults.standard.removeObject(forKey: "goalReminders")
        UserDefaults.standard.removeObject(forKey: "healthReminders")
        
        // Reset to default values
        currentTheme = .light
        waterUnit = .liters
    }
    
    func resetAllData() {
        resetSettings()
        // Add additional data clearing here
        UserDefaults.standard.removeObject(forKey: "tasks")
        UserDefaults.standard.removeObject(forKey: "goals")
        UserDefaults.standard.removeObject(forKey: "healthRecords")
        UserDefaults.standard.removeObject(forKey: "incomeRecords")
        UserDefaults.standard.removeObject(forKey: "expenses")
    }
}


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
    func converted(to unit: SettingsStore.WaterUnit) -> Double {
        switch unit {
        case .liters: return self
        case .ounces: return self * 33.814
        }
    }
}

extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: self.startOfWeek) ?? self
    }
}

extension GoalsStore {
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals.remove(at: index)
            saveGoals()
        }
    }
    
    func toggleGoalCompletion(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
            goals[index].progress = goals[index].isCompleted ? 1.0 : max(0, goals[index].progress - 0.1)
            saveGoals()
        }
    }
}
