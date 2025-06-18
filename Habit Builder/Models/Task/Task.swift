import Foundation
import SwiftUI

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
