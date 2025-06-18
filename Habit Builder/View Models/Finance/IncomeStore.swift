import SwiftUI
import AVFoundation
import Foundation

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
