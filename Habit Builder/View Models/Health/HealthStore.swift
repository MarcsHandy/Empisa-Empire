import SwiftUI
import AVFoundation
import Foundation

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
