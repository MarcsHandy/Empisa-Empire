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
