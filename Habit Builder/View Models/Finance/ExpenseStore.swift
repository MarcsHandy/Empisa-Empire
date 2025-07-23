import SwiftUI
import Foundation

class ExpenseStore: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet {
            saveExpenses()
        }
    }
    
    private var lastRecurringCheck: Date = Date.distantPast
    private let maxExpenses = 10_000
    private let calendar = Calendar.current
    
    init() {
        loadExpenses()
        checkRecurringExpenses()
    }
    
    func addExpense(_ expense: Expense) {
        guard expenses.count < maxExpenses else { return }
        expenses.append(expense)
    }
    
    func deleteExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses.remove(at: index)
        }
    }
    
    func expensesForDate(_ date: Date) -> [Expense] {
        let startOfDay = calendar.startOfDay(for: date)
        
        return expenses.filter { expense in
            if expense.isRecurring, let recurrence = expense.recurrence {
                switch recurrence {
                case .daily:
                    return true
                case .weekly:
                    return calendar.component(.weekday, from: startOfDay) == calendar.component(.weekday, from: expense.date)
                case .monthly:
                    return calendar.component(.day, from: startOfDay) == calendar.component(.day, from: expense.date)
                case .yearly:
                    let expenseComponents = calendar.dateComponents([.month, .day], from: expense.date)
                    let dateComponents = calendar.dateComponents([.month, .day], from: startOfDay)
                    return expenseComponents == dateComponents
                }
            } else {
                return calendar.isDate(expense.date, inSameDayAs: startOfDay)
            }
        }
    }
    
    func todayTotal() -> Double {
        expensesForDate(Date()).reduce(0) { $0 + $1.amount }
    }
    
    func weeklyTotal() -> Double {
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        return expenses.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek ||
            ($0.isRecurring && $0.recurrence == .weekly)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func monthlyTotal() -> Double {
        let currentMonth = calendar.component(.month, from: Date())
        return expenses.filter {
            calendar.component(.month, from: $0.date) == currentMonth ||
            ($0.isRecurring && $0.recurrence == .monthly)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private func checkRecurringExpenses() {
        let now = Date()
        guard now.timeIntervalSince(lastRecurringCheck) > 86400 else { return }
        lastRecurringCheck = now
        
        let today = calendar.startOfDay(for: now)
        let todayExpenses = expenses.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        let recurringToAdd = expenses.filter { expense in
            expense.isRecurring &&
            !todayExpenses.contains(where: { $0.id == expense.id })
        }
        
        let newExpenses = recurringToAdd.map { expense in
            Expense(
                id: UUID(),
                title: expense.title,
                amount: expense.amount,
                date: today,
                category: expense.category,
                isRecurring: true,
                recurrence: expense.recurrence
            )
        }
        
        expenses.append(contentsOf: newExpenses)
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
