import SwiftUI
import Foundation
import AVFoundation

struct TaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @State private var showingAddTask = false
    @State private var showingEditTask = false
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var swipedTaskId: UUID? = nil
    @State private var taskToEdit: Task? = nil
    @State private var calendarViewMode: CalendarViewMode = .month // Add this state variable
    
    enum CalendarViewMode: String, CaseIterable {
        case month = "Month"
        case week = "Week"
        case day = "Day"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar View
                    CalendarTaskView(
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth,
                        taskStore: taskStore,
                        viewMode: $calendarViewMode // Pass the view mode
                    )
                    .padding(.horizontal)
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(settings.currentTheme.backgroundColor.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // View mode picker - Add this segment control
                    Picker("View Mode", selection: $calendarViewMode) {
                        ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Task List with iOS-style swipe to delete and edit
                    LazyVStack(spacing: 8) {
                        ForEach(filteredTasks) { task in
                            TaskRowWithActions(
                                task: task,
                                swipedTaskId: $swipedTaskId,
                                onDelete: {
                                    deleteTask(task)
                                },
                                onEdit: {
                                    taskToEdit = task
                                }                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskStore: taskStore, selectedDate: $selectedDate)
                    .environmentObject(settings)
            }
            .sheet(item: $taskToEdit) { task in
                EditTaskView(taskStore: taskStore, task: task)
                    .environmentObject(settings)
            }
        }
    }
    
    private var filteredTasks: [Task] {
        taskStore.tasksForDate(selectedDate) // Sorting is already handled in tasksForDate
    }
    
    private func deleteTask(_ task: Task) {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation {
                taskStore.tasks.remove(at: index)
                taskStore.saveTasks()
            }
        }
    }
}


// iOS-style Swipe to Delete Row
struct iOSStyleSwipeToDeleteRow: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    @Binding var swipedTaskId: UUID?
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Delete button (hidden until swiped)
            if offset < 0 {
                HStack {
                    Spacer()
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
            
            // Task content
            TaskRow(task: task)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if swipedTaskId == nil || swipedTaskId == task.id {
                                if gesture.translation.width < 0 {
                                    offset = gesture.translation.width
                                    swipedTaskId = task.id
                                }
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring()) {
                                if gesture.translation.width < -50 {
                                    offset = -deleteButtonWidth
                                    swipedTaskId = task.id
                                } else {
                                    offset = 0
                                    swipedTaskId = nil
                                }
                            }
                        }
                )
                .onChange(of: swipedTaskId) { newValue in
                    if newValue != task.id && offset != 0 {
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

struct CalendarTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @ObservedObject var taskStore: TaskStore
    @Binding var viewMode: TaskView.CalendarViewMode // Add this
    
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Month header with navigation
            HStack {
                Text(currentMonth, formatter: monthFormatter)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        navigateMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                    
                    Button {
                        navigateMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            if viewMode != .day {
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(settings.currentTheme.textColor)
                    }
                }
            }
            
            // Dates grid - Updated to handle different view modes
            if viewMode == .month {
                monthView
            } else if viewMode == .week {
                weekView
            } else {
                dayView
            }
        }
    }
    
    private var monthView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInMonth(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: isSameDay(date, selectedDate),
                    hasTasks: taskStore.hasTasksOnDate(date),
                    isCurrentMonth: isSameMonth(date, currentMonth)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
    
    private var weekView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInWeek(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: isSameDay(date, selectedDate),
                    hasTasks: taskStore.hasTasksOnDate(date),
                    isCurrentMonth: isSameMonth(date, currentMonth)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
    
    private var dayView: some View {
        VStack {
            CalendarDayCell(
                date: selectedDate,
                isSelected: true,
                hasTasks: taskStore.hasTasksOnDate(selectedDate),
                isCurrentMonth: true
            )
            .frame(height: 60)
        }
    }
    
    private func navigateMonth(by months: Int) {
        if viewMode == .month || viewMode == .week {
            currentMonth = Calendar.current.date(byAdding: .month, value: months, to: currentMonth)!
        } else {
            selectedDate = Calendar.current.date(byAdding: .day, value: months > 0 ? 1 : -1, to: selectedDate)!
        }
    }
    
    private func daysInWeek() -> [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: selectedDate) else {
            return []
        }
        
        return Calendar.current.generateDates(
            for: DateInterval(start: weekInterval.start, end: weekInterval.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    private func CalendarDayCell(
        date: Date,
        isSelected: Bool,
        hasTasks: Bool,
        isCurrentMonth: Bool
    ) -> some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(settings.currentTheme.accentColor)
                    .frame(width: 30, height: 30)
            }
            
            Text(dayFormatter.string(from: date))
                .foregroundColor(
                    isSelected ? .white :
                    !isCurrentMonth ? settings.currentTheme.textColor.opacity(0.3) :
                    settings.currentTheme.textColor
                )
                .font(.system(size: 14))
            
            if hasTasks {
                Circle()
                    .fill(settings.currentTheme.primaryColor)
                    .frame(width: 5, height: 5)
                    .offset(y: 15)
            }
        }
        .frame(height: 40)
    }
    
    // Helper functions
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return Calendar.current.generateDates(
            for: dateInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .month)
    }
}

extension TaskStore {
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        let requestedDay = calendar.component(.day, from: date)
        let requestedMonth = calendar.component(.month, from: date)
        let requestedWeekday = calendar.component(.weekday, from: date)
        
        return tasks.filter { task in
            // Get components of the task's start date
            let taskDay = calendar.component(.day, from: task.startDate)
            let taskMonth = calendar.component(.month, from: task.startDate)
            let taskWeekday = calendar.component(.weekday, from: task.startDate)
            
            // Check if it's the exact date
            if calendar.isDate(task.startDate, inSameDayAs: date) {
                return true
            }
            
            // Check if this is a recurring task and the date is after the original task date
            guard let recurrence = task.recurrence, date > task.startDate else {
                return false
            }
            
            switch recurrence {
            case .daily:
                return true
            case .weekly:
                if let recurrenceDays = task.recurrenceDays {
                    return recurrenceDays.contains(requestedWeekday)
                } else {
                    // If no specific days set, use the original task's weekday
                    return requestedWeekday == taskWeekday
                }
            case .monthly:
                return requestedDay == taskDay
            case .yearly:
                return requestedDay == taskDay && requestedMonth == taskMonth
            case .none:
                return false
            }
        }
        .sorted {
            // First sort by start time
            if $0.startDate != $1.startDate {
                return $0.startDate < $1.startDate
            }
            // If start times are equal, sort by end time
            return $0.endDate < $1.endDate
        }
    }
    
    func hasTasksOnDate(_ date: Date) -> Bool {
        return !tasksForDate(date).isEmpty
    }
}

// TaskRow.swift
struct TaskRow: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time indicator
            VStack(alignment: .leading) {
                Text(task.startDate, style: .time)
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                if task.startDate != task.endDate {
                    Text(task.endDate, style: .time)
                        .font(.caption)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
            }
            .frame(width: 60)
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Color indicator
            Circle()
                .fill(Color(task.color.rawValue))
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(8)
    }
}

struct TaskRowWithActions: View {
    @EnvironmentObject var settings: SettingsStore
    let task: Task
    @Binding var swipedTaskId: UUID?
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteButtonWidth: CGFloat = 80
    private let editButtonWidth: CGFloat = 44
    
    var body: some View {
        ZStack {
            // Delete button (hidden until swiped)
            if offset < 0 {
                HStack {
                    Spacer()
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
            
            // Task content with edit button
            HStack {
                TaskRow(task: task)
                
                // Edit button
                if offset == 0 {
                    Button(action: {
                        onEdit()
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                            .frame(width: editButtonWidth)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if swipedTaskId == nil || swipedTaskId == task.id {
                            offset = gesture.translation.width
                            swipedTaskId = task.id
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -50 {
                                offset = -deleteButtonWidth
                                swipedTaskId = task.id
                            } else if gesture.translation.width > 50 {
                                offset = 0
                                swipedTaskId = nil
                            } else {
                                offset = 0
                                swipedTaskId = nil
                            }
                        }
                    }
            )
            .onChange(of: swipedTaskId) { newValue in
                if newValue != task.id && offset != 0 {
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

struct EditTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @Environment(\.presentationMode) var presentationMode
    
    let task: Task
    @State private var editedTitle: String
    @State private var editedNotes: String
    @State private var editedColor: Task.TaskColor
    @State private var editedIsAllDay: Bool
    @State private var editedRecurrence: Task.Recurrence?
    @State private var editedRecurrenceDays: [Int]?
    
    // Date and time state
    @State private var startDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    
    init(taskStore: TaskStore, task: Task) {
        self.taskStore = taskStore
        self.task = task
        _editedTitle = State(initialValue: task.title)
        _editedNotes = State(initialValue: task.notes)
        _editedColor = State(initialValue: task.color)
        _editedIsAllDay = State(initialValue: Calendar.current.isDate(task.startDate, inSameDayAs: task.endDate))
        _editedRecurrence = State(initialValue: task.recurrence)
        _editedRecurrenceDays = State(initialValue: task.recurrenceDays)
        
        // Initialize date and time components
        _ = Calendar.current
        _startDate = State(initialValue: task.startDate)
        _startTime = State(initialValue: task.startDate)
        _endTime = State(initialValue: task.endDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                taskDetailsSection
                recurrenceSection
                saveButtonSection
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var taskDetailsSection: some View {
        Section(header: sectionHeader("Task Details")) {
            TextField("Title", text: $editedTitle)
            TextField("Notes (optional)", text: $editedNotes)
            
            Toggle("All-day", isOn: $editedIsAllDay)
            
            if !editedIsAllDay {
                DatePicker("Start Date",
                         selection: $startDate,
                         displayedComponents: .date)
                DatePicker("Start Time",
                         selection: $startTime,
                         displayedComponents: .hourAndMinute)
                DatePicker("End Time",
                         selection: $endTime,
                         in: startTime...,  // Ensures end time is after start time
                         displayedComponents: .hourAndMinute)
            }
            
            colorPicker
        }
    }
    
    private var colorPicker: some View {
        Picker("Color", selection: $editedColor) {
            ForEach(Task.TaskColor.allCases, id: \.self) { color in
                Text(color.rawValue.capitalized).tag(color)
            }
        }
    }
    
    private var recurrenceSection: some View {
        Section(header: sectionHeader("Recurrence")) {
            recurrencePicker
            if editedRecurrence == .weekly {
                weekdaySelection
            }
        }
    }
    
    private var recurrencePicker: some View {
        Picker("Repeat", selection: Binding<Task.Recurrence>(
            get: { editedRecurrence ?? Task.Recurrence.none },
            set: { newValue in
                editedRecurrence = (newValue == Task.Recurrence.none) ? nil : newValue
            }
        )) {
            ForEach(Task.Recurrence.allCases, id: \.self) { option in
                Text(option.rawValue.capitalized).tag(option)
            }
        }
        .pickerStyle(.menu)
    }
    
    private var weekdaySelection: some View {
        WeekdaySelectionView(selectedDays: Binding(
            get: { Set(editedRecurrenceDays?.compactMap { Weekday(rawValue: $0) } ?? []) },
            set: { editedRecurrenceDays = Array($0).map { $0.rawValue } }
        ))
    }
    
    private var saveButtonSection: some View {
        Section {
            Button("Save Changes") {
                saveChanges()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(settings.currentTheme.accentColor)
    }
    
    private func saveChanges() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            
            if editedIsAllDay {
                updatedTask.startDate = startDate.startOfDay
                updatedTask.endDate = startDate.endOfDay
            } else {
                // Combine date from startDate with time from pickers
                let calendar = Calendar.current
                let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                
                let newStartDate = calendar.date(
                    bySettingHour: startComponents.hour ?? 0,
                    minute: startComponents.minute ?? 0,
                    second: 0,
                    of: startDate
                ) ?? startDate
                
                var newEndDate = calendar.date(
                    bySettingHour: endComponents.hour ?? 0,
                    minute: endComponents.minute ?? 0,
                    second: 0,
                    of: startDate
                ) ?? startDate
                
                // Ensure end time is after start time
                if newEndDate <= newStartDate {
                    newEndDate = calendar.date(byAdding: .hour, value: 1, to: newStartDate) ?? newStartDate
                }
                
                updatedTask.startDate = newStartDate
                updatedTask.endDate = newEndDate
            }
            
            updatedTask.title = editedTitle
            updatedTask.notes = editedNotes
            updatedTask.color = editedColor
            updatedTask.recurrence = editedRecurrence
            updatedTask.recurrenceDays = editedRecurrenceDays
            
            taskStore.tasks[index] = updatedTask
            taskStore.saveTasks()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// AddTaskView.swift
struct AddTaskView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var taskStore: TaskStore
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var notes = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var color: Task.TaskColor = .blue
    @State private var isAllDay = false
    @State private var recurrenceOption: RecurrenceOption = .none
    @State private var selectedDays: Set<Weekday> = []
    
    enum RecurrenceOption: String, CaseIterable {
        case none = "Does not repeat"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").foregroundColor(settings.currentTheme.accentColor)) {
                    TextField("Title", text: $title)
                    TextField("Notes (optional)", text: $notes)
                    
                    Toggle("All-day", isOn: $isAllDay)
                    
                    if !isAllDay {
                        DatePicker("Start Time",
                                 selection: $startDate,
                                 displayedComponents: .hourAndMinute)
                        DatePicker("End Time",
                                 selection: $endDate,
                                 in: startDate...,
                                 displayedComponents: .hourAndMinute)
                    }
                    
                    Picker("Color", selection: $color) {
                        ForEach(Task.TaskColor.allCases, id: \.self) { color in
                            Text(color.rawValue.capitalized).tag(color)
                        }
                    }
                }
                
                Section(header: Text("Recurrence")) {
                    Picker("Repeat", selection: $recurrenceOption) {
                        ForEach(RecurrenceOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if recurrenceOption == .weekly {
                        WeekdaySelectionView(selectedDays: $selectedDays)
                    }
                }
                
                Section {
                    Button("Add Task") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                startDate = calendar.date(from: components) ?? Date()
                endDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? Date()
                
                // Preselect current day for weekly recurrence
                let weekday = calendar.component(.weekday, from: selectedDate)
                if let currentWeekday = Weekday(rawValue: weekday) {
                    selectedDays = [currentWeekday]
                }
            }
        }
    }
    
    private func addTask() {
        var recurrence: Task.Recurrence?
        var recurrenceDays: [Int]?
        
        switch recurrenceOption {
        case .none:
            recurrence = nil
            recurrenceDays = nil
        case .daily:
            recurrence = .daily
            recurrenceDays = nil
        case .weekly:
            recurrence = .weekly
            recurrenceDays = selectedDays.map { $0.rawValue }
        case .monthly:
            recurrence = .monthly
            recurrenceDays = nil
        case .yearly:
            recurrence = .yearly
            recurrenceDays = nil
        }
        
        let newTask = Task(
            title: title,
            notes: notes,
            startDate: isAllDay ? startDate.startOfDay : startDate,
            endDate: isAllDay ? startDate.endOfDay : endDate,
            color: color,
            recurrence: recurrence,
            recurrenceDays: recurrenceDays
        )
        
        taskStore.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

struct WeekdaySelectionView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedDays: Set<Weekday>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Repeat on:")
                .font(.subheadline)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            
            HStack {
                ForEach(Weekday.allCases) { day in
                    Button(action: {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }) {
                        Text(day.shortName)
                            .font(.caption)
                            .frame(width: 32, height: 32)
                            .background(selectedDays.contains(day) ?
                                        settings.currentTheme.accentColor :
                                        settings.currentTheme.backgroundColor.opacity(0.3))
                            .foregroundColor(selectedDays.contains(day) ?
                                            .white :
                                            settings.currentTheme.textColor)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
    }
}


// Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}
