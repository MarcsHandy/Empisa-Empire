import SwiftUI
import AVFoundation
import Foundation

struct IncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @ObservedObject var expenseStore: ExpenseStore
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var showingEditIncome = false
    @State private var incomeToEdit: IncomeRecord?
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary Cards
                        VStack(spacing: 16) {
                            
                            // Calendar View
                            CalendarView(incomeStore: incomeStore)
                                .frame(height: 300)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                                              settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                                              Color.white)
                                        .shadow(color: settings.currentTheme.textColor.opacity(0.1), radius: 5)
                                )
                                .padding(.horizontal)
                            
                            // Income Cards
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Income Today",
                                    amount: incomeStore.todayTotal(),
                                    color: settings.currentTheme.accentColor
                                )
                                SummaryCard(
                                    title: "Income Week",
                                    amount: incomeStore.weeklyTotal(),
                                    color: settings.currentTheme.primaryColor
                                )
                                SummaryCard(
                                    title: "Income Month",
                                    amount: incomeStore.monthlyTotal(),
                                    color: settings.currentTheme.secondaryColor
                                )
                            }
                            
                            // Expense Cards
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Expenses Today",
                                    amount: expenseStore.todayTotal(),
                                    color: Color.red
                                )
                                SummaryCard(
                                    title: "Expenses Week",
                                    amount: expenseStore.weeklyTotal(),
                                    color: Color.orange
                                )
                                SummaryCard(
                                    title: "Expenses Month",
                                    amount: expenseStore.monthlyTotal(),
                                    color: Color.yellow
                                )
                            }
                            
                            // Net Cards
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Net Today",
                                    amount: incomeStore.todayTotal() - expenseStore.todayTotal(),
                                    color: incomeStore.todayTotal() - expenseStore.todayTotal() >= 0 ? Color.green : Color.red
                                )
                                SummaryCard(
                                    title: "Net Week",
                                    amount: incomeStore.weeklyTotal() - expenseStore.weeklyTotal(),
                                    color: incomeStore.weeklyTotal() - expenseStore.weeklyTotal() >= 0 ? Color.green : Color.red
                                )
                                SummaryCard(
                                    title: "Net Month",
                                    amount: incomeStore.monthlyTotal() - expenseStore.monthlyTotal(),
                                    color: incomeStore.monthlyTotal() - expenseStore.monthlyTotal() >= 0 ? Color.green : Color.red
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Add Expense Button
                        Button(action: {
                            showingAddExpense = true
                        }) {
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                Text("Add Expense")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Recent Transactions
                        VStack(spacing: 16) {
                            Text("Recent Transactions")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            // Recent Income
                            ForEach(incomeStore.records.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                TransactionRow(
                                    title: "Income",
                                    amount: record.amount,
                                    date: record.date,
                                    isIncome: true
                                )
                            }
                            
                            // Recent Expenses
                            ForEach(expenseStore.expenses.sorted(by: { $0.date > $1.date }).prefix(3)) { expense in
                                TransactionRow(
                                    title: expense.title,
                                    amount: -expense.amount,
                                    date: expense.date,
                                    isIncome: false,
                                    category: expense.category.rawValue
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Income & Expenses")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { showingAddIncome = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddIncome) {
                    AddIncomeView(incomeStore: incomeStore)
                }
                .sheet(isPresented: $showingAddExpense) {
                    AddExpenseView(expenseStore: expenseStore)
                }
                .sheet(isPresented: $showingEditIncome) {
                    if let incomeToEdit = incomeToEdit {
                        EditIncomeView(incomeStore: incomeStore, record: incomeToEdit)
                    }
                }
            }
        }
    }
}

struct AddExpenseView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var expenseStore: ExpenseStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var category = Expense.ExpenseCategory.other
    @State private var isRecurring = false
    @State private var recurrence: Expense.Recurrence?
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Expense Details").foregroundColor(settings.currentTheme.accentColor)) {
                        TextField("Title", text: $title)
                            .foregroundColor(settings.currentTheme.textColor)
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(settings.currentTheme.textColor)
                        
                        Picker("Category", selection: $category) {
                            ForEach(Expense.ExpenseCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .foregroundColor(settings.currentTheme.textColor)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section(header: Text("Recurrence").foregroundColor(settings.currentTheme.accentColor)) {
                        Toggle("Recurring Expense", isOn: $isRecurring)
                        
                        if isRecurring {
                            Picker("Recurrence", selection: $recurrence) {
                                ForEach(Expense.Recurrence.allCases, id: \.self) { recurrence in
                                    Text(recurrence.rawValue).tag(recurrence)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: addExpense) {
                            HStack {
                                Spacer()
                                Text("Add Expense")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                        .disabled(title.isEmpty || amount.isEmpty || (isRecurring && recurrence == nil))
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("New Expense")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
        }
        .accentColor(settings.currentTheme.accentColor)
    }
    
    private func addExpense() {
        if let amountValue = Double(amount) {
            let expense = Expense(
                id: UUID(),
                title: title,
                amount: amountValue,
                date: date,
                category: category,
                isRecurring: isRecurring,
                recurrence: isRecurring ? recurrence : nil
            )
            expenseStore.addExpense(expense)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TransactionRow: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let amount: Double
    let date: Date
    let isIncome: Bool
    var category: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                if let category = category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
                
                Text(date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Spacer()
            
            Text(amount, format: .currency(code: "USD"))
                .font(.body.bold())
                .foregroundColor(isIncome ? Color.green : Color.red)
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(10)
    }
}

// New view for income row with swipe actions
struct IncomeRowWithActions: View {
    @EnvironmentObject var settings: SettingsStore
    let record: IncomeRecord
    @Binding var swipedIncomeId: UUID?
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 80
    private let editButtonWidth: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Delete button (hidden until swiped)
            if offset < 0 {
                HStack {
                    Spacer()
                    // Edit button
                    Button(action: {
                        withAnimation(.easeOut) {
                            offset = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onEdit()
                            }
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: editButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Delete button
                    Button(action: {
                        withAnimation(.easeOut) {
                            offset = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDelete()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: deleteButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.move(edge: .trailing))
            }
            
            // Income content
            IncomeRow(record: record)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if swipedIncomeId == nil || swipedIncomeId == record.id {
                                if gesture.translation.width < 0 {
                                    offset = gesture.translation.width
                                    swipedIncomeId = record.id
                                }
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring()) {
                                if gesture.translation.width < -50 {
                                    offset = -(deleteButtonWidth + editButtonWidth)
                                    swipedIncomeId = record.id
                                } else {
                                    offset = 0
                                    swipedIncomeId = nil
                                }
                            }
                        }
                )
                .onChange(of: swipedIncomeId) { newValue in
                    if newValue != record.id && offset != 0 {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        }
        .frame(height: 60)
        .contentShape(Rectangle())
    }
}

// New view for editing income
struct EditIncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @Environment(\.presentationMode) var presentationMode
    
    let record: IncomeRecord
    @State private var amount: String
    @State private var date: Date
    
    init(incomeStore: IncomeStore, record: IncomeRecord) {
        self.incomeStore = incomeStore
        self.record = record
        _amount = State(initialValue: String(format: "%.2f", record.amount))
        _date = State(initialValue: record.date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Income Details").foregroundColor(settings.currentTheme.accentColor)) {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(settings.currentTheme.textColor)
                            .colorScheme(settings.currentTheme == .darkGold ? .dark : .light)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: saveChanges) {
                            HStack {
                                Spacer()
                                Text("Save Changes")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [
                                    settings.currentTheme.accentColor,
                                    settings.currentTheme.primaryColor
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(10)
                        }
                        .disabled(amount.isEmpty || Double(amount) == nil)
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Edit Income")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
        }
        .accentColor(settings.currentTheme.accentColor)
    }
    
    private func saveChanges() {
        if let amountValue = Double(amount) {
            incomeStore.updateRecord(record, withAmount: amountValue, newDate: date)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// Add these methods to your IncomeStore class


struct SummaryCard: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Text(amount, format: .currency(code: "USD"))
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct CalendarView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack {
            // Month and year header
            HStack {
                Text(currentDate, format: .dateTime.year().month())
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(settings.currentTheme.accentColor)
                }
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(settings.currentTheme.accentColor)
                }
            }
            .padding(.bottom, 8)
            
            // Days of week header
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(settings.currentTheme.textColor)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if calendar.isDate(date, equalTo: currentDate, toGranularity: .month) {
                        CalendarDayView(date: date, incomeStore: incomeStore)
                    } else {
                        Text("")
                    }
                }
            }
        }
        .foregroundColor(settings.currentTheme.textColor)
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDates(for: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
    
    private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
    }
    
    private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
    }
}

struct CalendarDayView: View {
    @EnvironmentObject var settings: SettingsStore
    let date: Date
    @ObservedObject var incomeStore: IncomeStore
    
    private var dayIncome: Double {
        incomeStore.records.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(Calendar.current.component(.day, from: date)))
                .font(.system(size: 14))
                .foregroundColor(isToday ? .white : settings.currentTheme.textColor)
                .frame(width: 24, height: 24)
                .background(isToday ? settings.currentTheme.accentColor : Color.clear)
                .clipShape(Circle())
            
            if dayIncome > 0 {
                Text(dayIncome, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 10))
                    .foregroundColor(settings.currentTheme == .cyberpunk ? .neonGreen : .kenteGreen)
            }
        }
        .frame(height: 40)
    }
}

struct IncomeRow: View {
    @EnvironmentObject var settings: SettingsStore
    let record: IncomeRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.date, format: .dateTime.day().month().year())
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Text(record.date, format: .dateTime.weekday(.wide))
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Spacer()
            
            Text(record.amount, format: .currency(code: "USD"))
                .font(.title3.bold())
                .foregroundColor(settings.currentTheme.accentColor)
        }
        .padding(.vertical, 8)
    }
}

struct AddIncomeView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var incomeStore: IncomeStore
    @State private var amount = ""
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Income Details").foregroundColor(settings.currentTheme.accentColor)) {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(settings.currentTheme.textColor)
                            .colorScheme(settings.currentTheme == .darkGold ? .dark : .light)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: {
                            if let amountValue = Double(amount) {
                                incomeStore.addRecord(amount: amountValue, date: date)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Add Income")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [
                                    settings.currentTheme.accentColor,
                                    settings.currentTheme.primaryColor
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(10)
                        }
                        .disabled(amount.isEmpty || Double(amount) == nil)
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Add Income")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
        }
        .accentColor(settings.currentTheme.accentColor)
    }
}
