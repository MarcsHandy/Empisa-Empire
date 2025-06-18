import Foundation

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
