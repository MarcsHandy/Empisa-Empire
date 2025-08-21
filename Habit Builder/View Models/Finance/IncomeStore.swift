import Foundation

@MainActor
final class IncomeStore: ObservableObject {
    @Published private(set) var records: [IncomeRecord] = [] {
        didSet {
            guard !isInitializing else { return }
            saveRecords()
        }
    }
    
    // MARK: - State Management
    private var isInitializing = false
    private var isLoading = false
    private var isSaving = false
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    init() {
        initializeStore()
    }
    
    private func initializeStore() {
        isInitializing = true
        loadRecords()
        isInitializing = false
    }
    
    // MARK: - Public Methods
    func addRecord(amount: Double, date: Date = Date()) {
        let newRecord = IncomeRecord(date: date, amount: amount)
        records.append(newRecord)
    }
    
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
    }
    
    func deleteRecord(_ record: IncomeRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records.remove(at: index)
        }
    }
    
    func updateRecord(_ record: IncomeRecord, withAmount amount: Double, newDate: Date) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index].amount = amount
            records[index].date = newDate
        }
    }
    
    // MARK: - Totals Calculation
    func todayTotal() -> Double {
        let today = calendar.startOfDay(for: Date())
        return records.filter {
            calendar.isDate($0.date, inSameDayAs: today)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func weeklyTotal() -> Double {
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        return records.filter {
            calendar.component(.weekOfYear, from: $0.date) == currentWeek
        }.reduce(0) { $0 + $1.amount }
    }
    
    func monthlyTotal() -> Double {
        let currentMonth = calendar.component(.month, from: Date())
        return records.filter {
            calendar.component(.month, from: $0.date) == currentMonth
        }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Persistence
    private func saveRecords() {
        guard !isSaving else { return }
        isSaving = true
        
        // Create local copy for thread safety
        let recordsToSave = records
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            do {
                let encoded = try JSONEncoder().encode(recordsToSave)
                
                // Size check for safety
                if encoded.count > 100_000 {
                    print("⚠️ Large income data: \(encoded.count) bytes")
                }
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(encoded, forKey: "incomeRecords")
                    self?.isSaving = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("🚨 Income save error: \(error.localizedDescription)")
                    self?.isSaving = false
                }
            }
        }
    }
    
    private func loadRecords() {
        isLoading = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            do {
                if let data = UserDefaults.standard.data(forKey: "incomeRecords") {
                    let decoded = try JSONDecoder().decode([IncomeRecord].self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.records = decoded
                        self?.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("🚨 Income load error: \(error.localizedDescription)")
                    self?.isLoading = false
                }
            }
        }
    }
}
