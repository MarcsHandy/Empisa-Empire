import SwiftUI
import AVFoundation
import Foundation

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
    
    // Daily Revision Methods
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
    
    // Weekly Retrospective Methods
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
    
    // Data Persistence
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
