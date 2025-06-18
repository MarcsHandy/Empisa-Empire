import SwiftUI
import AVFoundation
import Foundation

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
