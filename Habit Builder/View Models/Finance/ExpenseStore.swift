import Foundation

@MainActor
final class ExpenseStore: ObservableObject {
    @Published private(set) var expenses: [Expense] = [] {
        didSet {
            guard !isInitializing else { return }
            saveExpenses()
        }
    }
    
    // MARK: - State Management
    private var isInitializing = false
    private var isLoading = false
    private var isSaving = false
    private var lastRecurringCheck = Date.distantPast
    private let calendar = Calendar.current
    private let maxExpenses = 10_000
    
    // MARK: - Initialization
    init() {
        isInitializing = true
        loadExpenses()
        isInitializing = false
        
        // Schedule recurring check after slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.checkRecurringExpenses()
        }
    }
    
    // MARK: - Public Methods
    func addExpense(_ expense: Expense) {
        guard expenses.count < maxExpenses else { return }
        expenses.append(expense)
    }
    
    func deleteExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses.remove(at: index)
        }
    }
    
    // MARK: - Data Access
    var todayTotal: Double {
        expensesForDate(Date()).reduce(0) { $0 + $1.amount }
    }
    
    var weeklyTotal: Double {
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        return expenses.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek ||
            ($0.isRecurring && $0.recurrence == .weekly)
        }.reduce(0) { $0 + $1.amount }
    }
    
    var monthlyTotal: Double {
        let currentMonth = calendar.component(.month, from: Date())
        return expenses.filter {
            calendar.component(.month, from: $0.date) == currentMonth ||
            ($0.isRecurring && $0.recurrence == .monthly)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func expensesForDate(_ date: Date) -> [Expense] {
        let startOfDay = calendar.startOfDay(for: date)
        
        return expenses.filter { expense in
            if expense.isRecurring, let recurrence = expense.recurrence {
                switch recurrence {
                case .daily: return true
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
    
    // MARK: - Persistence
    private func saveExpenses() {
        guard !isSaving else { return }
        isSaving = true
        
        let expensesToSave = expenses
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            do {
                let encoded = try JSONEncoder().encode(expensesToSave)
                
                // Validate size before saving
                if encoded.count > 100_000 {
                    print("⚠️ Large expenses data: \(encoded.count) bytes")
                }
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(encoded, forKey: "expenses")
                    self?.isSaving = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("🚨 Save error: \(error.localizedDescription)")
                    self?.isSaving = false
                }
            }
        }
    }
    
    private func loadExpenses() {
        guard !isLoading else { return }
        isLoading = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            do {
                if let data = UserDefaults.standard.data(forKey: "expenses") {
                    let decoded = try JSONDecoder().decode([Expense].self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.expenses = decoded.filter { $0.amount >= 0 } // Basic validation
                        self?.isLoading = false
                        print("✅ Successfully loaded \(decoded.count) expenses")
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("🚨 Load error: \(error.localizedDescription)")
                    self?.expenses = [] // Reset to empty array
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Recurring Expenses
    private func checkRecurringExpenses() {
        let now = Date()
        guard now.timeIntervalSince(lastRecurringCheck) > 86400 else { return }
        lastRecurringCheck = now
        
        let today = calendar.startOfDay(for: now)
        let todayExpenses = expenses.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        let recurringToAdd = expenses.filter { expense in
            guard expense.isRecurring,
                  !calendar.isDate(expense.date, inSameDayAs: today),
                  !todayExpenses.contains(where: { $0.isDuplicate(of: expense) })
            else { return false }
            return true
        }
        
        guard !recurringToAdd.isEmpty else { return }
        
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
}

// Add to your Expense model:
extension Expense {
    func isDuplicate(of other: Expense) -> Bool {
        return self.title == other.title &&
               self.amount == other.amount &&
               self.category == other.category &&
               self.recurrence == other.recurrence
    }
}
