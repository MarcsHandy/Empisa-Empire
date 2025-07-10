import SwiftUI
import AVFoundation
import Foundation

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedDate = Date()
    
    init() {
        loadTasks()
    }
    
    func addTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.startDate > task.startDate }) {
            tasks.insert(task, at: index)
        } else {
            tasks.append(task)
        }
        saveTasks()
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        let requestedDay = calendar.component(.day, from: date)
        let requestedMonth = calendar.component(.month, from: date)
        let requestedWeekday = calendar.component(.weekday, from: date)

        var tasksForThisDate: [Task] = []

        for task in tasks {
            // If the task occurs exactly on this date
            if calendar.isDate(task.startDate, inSameDayAs: date) {
                tasksForThisDate.append(task)
                continue
            }

            // Handle recurrence
            guard let recurrence = task.recurrence, date > task.startDate else { continue }

            let taskDay = calendar.component(.day, from: task.startDate)
            let taskMonth = calendar.component(.month, from: task.startDate)
            let taskWeekday = calendar.component(.weekday, from: task.startDate)

            var isRecurringToday = false

            switch recurrence {
            case .daily:
                isRecurringToday = true
            case .weekly:
                if let recurrenceDays = task.recurrenceDays {
                    isRecurringToday = recurrenceDays.contains(requestedWeekday)
                } else {
                    isRecurringToday = requestedWeekday == taskWeekday
                }
            case .monthly:
                isRecurringToday = requestedDay == taskDay
            case .yearly:
                isRecurringToday = requestedDay == taskDay && requestedMonth == taskMonth
            case .none:
                break
            }

            if isRecurringToday {
                // Create a copy of the task adjusted to this date
                let timeInterval = task.endDate.timeIntervalSince(task.startDate)
                let newStart = calendar.date(
                    bySettingHour: calendar.component(.hour, from: task.startDate),
                    minute: calendar.component(.minute, from: task.startDate),
                    second: 0,
                    of: date
                ) ?? date
                let newEnd = newStart.addingTimeInterval(timeInterval)

                var recurringCopy = task
                recurringCopy.startDate = newStart
                recurringCopy.endDate = newEnd
                tasksForThisDate.append(recurringCopy)
            }
        }

        // Sort all tasks by startDate (now that recurring ones are adjusted)
        return tasksForThisDate.sorted {
            if $0.startDate != $1.startDate {
                return $0.startDate < $1.startDate
            }
            return $0.endDate < $1.endDate
        }
    }
    func hasTasksOnDate(_ date: Date) -> Bool {
        return !tasksForDate(date).isEmpty
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
            tasks = decoded.sorted {
                if $0.startDate != $1.startDate {
                    return $0.startDate < $1.startDate
                }
                return $0.endDate < $1.endDate
            }
        }
    }
    
    func updateTask(_ updatedTask: Task) {
        // Remove the old task if it exists
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks.remove(at: index)
            
            // Find the correct insertion point for the updated task
            let insertionIndex: Int
            if let firstLaterIndex = tasks.firstIndex(where: { $0.startDate > updatedTask.startDate }) {
                insertionIndex = firstLaterIndex
            } else {
                insertionIndex = tasks.endIndex
            }
            
            // Insert the updated task at the correct position
            tasks.insert(updatedTask, at: insertionIndex)
            
            // Save changes
            saveTasks()
        }
    }
}
