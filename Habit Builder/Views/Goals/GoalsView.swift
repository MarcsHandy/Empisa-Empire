import SwiftUI
import AVFoundation
import Foundation

struct GoalsView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var goalsStore = GoalsStore()
    @State private var showingAddGoal = false
    @State private var selectedGoalType: GoalType = .daily
    @State private var searchText = ""
    @State private var showingCompleted = true
    @State private var editingGoal: Goal? = nil

    var filteredGoals: [Goal] {
        var goals = goalsStore.goalsForType(selectedGoalType)
        
        if !searchText.isEmpty {
            goals = goals.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if !showingCompleted {
            goals = goals.filter { !$0.isCompleted }
        }
        
        return goals.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            return $0.targetDate < $1.targetDate
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                GoalFilterView(
                    searchText: $searchText,
                    selectedGoalType: $selectedGoalType,
                    showingCompleted: $showingCompleted
                )
                
                if filteredGoals.isEmpty {
                    EmptyGoalsView(goalType: selectedGoalType)
                } else {
                    GoalListView(
                        goalsStore: goalsStore,
                        goals: filteredGoals,
                        editingGoal: $editingGoal
                    )
                }
            }
            .navigationTitle("My Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddEditGoalView(
                    goalsStore: goalsStore,
                    goal: nil,
                    selectedType: selectedGoalType
                )
            }
            .sheet(item: $editingGoal) { goal in
                AddEditGoalView(
                    goalsStore: goalsStore,
                    goal: goal,
                    selectedType: goal.type
                )
            }
        }
    }
}

struct AddEditGoalView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var goalsStore: GoalsStore
    var goal: Goal?
    let selectedType: GoalType
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var description: String
    @State private var targetDate: Date
    @State private var progress: Double
    @State private var showingDatePicker = false
    
    init(goalsStore: GoalsStore, goal: Goal?, selectedType: GoalType) {
        self.goalsStore = goalsStore
        self.goal = goal
        self.selectedType = selectedType
        
        if let existingGoal = goal {
            _title = State(initialValue: existingGoal.title)
            _description = State(initialValue: existingGoal.description)
            _targetDate = State(initialValue: existingGoal.targetDate)
            _progress = State(initialValue: existingGoal.progress)
        } else {
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            
            // Set default target date based on goal type
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            
            switch selectedType {
            case .daily:
                dateComponents.day = 1
            case .monthly:
                dateComponents.month = 1
            case .quarterly:
                dateComponents.month = 3
            }
            
            _targetDate = State(initialValue: calendar.date(byAdding: dateComponents, to: Date()) ?? Date())
            _progress = State(initialValue: 0)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Goal title", text: $title)
                        .font(.headline)
                    
                    TextField("Description (optional)", text: $description)
                }
                
                Section {
                    HStack {
                        Text("Goal Type")
                        Spacer()
                        Text(selectedType.rawValue)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    }
                    
                    HStack {
                        Text("Target Date")
                        Spacer()
                        Button(action: { showingDatePicker.toggle() }) {
                            Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(settings.currentTheme.textColor)
                        }
                    }
                    
                    if showingDatePicker {
                        DatePicker(
                            "Select target date",
                            selection: $targetDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Progress: \(Int(progress * 100))%")
                            .font(.subheadline)
                        
                        Slider(value: $progress, in: 0...1, step: 0.05)
                            .tint(progress >= 1 ? .green : settings.currentTheme.accentColor)
                        
                        HStack {
                            ForEach([0, 0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                                Button(action: { progress = value }) {
                                    Text("\(Int(value * 100))%")
                                        .font(.caption)
                                        .padding(4)
                                        .frame(minWidth: 30)
                                        .background(progress == value ? settings.currentTheme.accentColor.opacity(0.3) : Color.clear)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: saveGoal) {
                        HStack {
                            Spacer()
                            Text(goal == nil ? "Add Goal" : "Save Changes")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                    .tint(settings.currentTheme.accentColor)
                }
                
                if goal != nil {
                    Section {
                        Button(role: .destructive) {
                            if let goal = goal {
                                goalsStore.deleteGoal(goal)
                            }
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Goal")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(goal == nil ? "New \(selectedType.rawValue) Goal" : "Edit Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveGoal() {
        let updatedGoal = Goal(
            id: goal?.id ?? UUID(),
            type: selectedType,
            title: title,
            description: description,
            isCompleted: progress >= 1.0,
            targetDate: targetDate,
            progress: progress
        )
        
        if goal != nil {
            goalsStore.updateGoal(updatedGoal)
        } else {
            goalsStore.addGoal(updatedGoal)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct GoalCard: View {
    @EnvironmentObject var settings: SettingsStore
    let goal: Goal
    
    private var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0
    }
    
    private var progressColor: Color {
        if goal.progress >= 1.0 {
            return .green
        } else if daysRemaining <= 0 {
            return .red
        } else {
            return settings.currentTheme.accentColor
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                        .strikethrough(goal.isCompleted)
                    
                    if !goal.description.isEmpty {
                        Text(goal.description)
                            .font(.subheadline)
                            .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                            .strikethrough(goal.isCompleted)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else {
                        Text("\(daysRemaining > 0 ? daysRemaining : 0)d")
                            .font(.caption)
                            .foregroundColor(daysRemaining <= 0 ? .red : settings.currentTheme.textColor.opacity(0.7))
                            .padding(6)
                            .background(Circle().fill(daysRemaining <= 0 ? Color.red.opacity(0.2) : settings.currentTheme.backgroundColor.opacity(0.3)))
                    }
                    
                    Text(goal.targetDate, formatter: dateFormatter)
                        .font(.caption2)
                        .foregroundColor(settings.currentTheme.textColor.opacity(0.5))
                }
            }
            
            ProgressView(value: goal.progress, total: 1.0)
                .tint(progressColor)
            
            HStack {
                Text("\(Int(goal.progress * 100))% complete")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                
                Spacer()
                
                Text(goal.type.rawValue)
                    .font(.caption)
                    .padding(4)
                    .padding(.horizontal, 4)
                    .background(Capsule().fill(settings.currentTheme.backgroundColor.opacity(0.3)))
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(settings.currentTheme.backgroundColor.opacity(0.3), lineWidth: 1)
        )
        .opacity(goal.isCompleted ? 0.8 : 1.0)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct EmptyGoalsView: View {
    @EnvironmentObject var settings: SettingsStore
    let goalType: GoalType
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(settings.currentTheme.textColor.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No \(goalType.rawValue.lowercased()) goals yet")
                    .font(.title3)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Text("Add your first \(goalType.rawValue.lowercased()) goal to get started")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddGoalView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var goalsStore: GoalsStore
    let selectedType: GoalType
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetDate: Date
    @State private var progress: Double = 0
    @State private var showingDatePicker = false
    
    init(goalsStore: GoalsStore, selectedType: GoalType) {
        self.goalsStore = goalsStore
        self.selectedType = selectedType
        
        // Set default target date based on goal type
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch selectedType {
        case .daily:
            dateComponents.day = 1
        case .monthly:
            dateComponents.month = 1
        case .quarterly:
            dateComponents.month = 3
        }
        
        _targetDate = State(initialValue: calendar.date(byAdding: dateComponents, to: Date()) ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Goal title", text: $title)
                        .font(.headline)
                    
                    TextField("Description (optional)", text: $description)
                }
                
                Section {
                    HStack {
                        Text("Target Date")
                        Spacer()
                        Button(action: { showingDatePicker.toggle() }) {
                            Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(settings.currentTheme.textColor)
                        }
                    }
                    
                    if showingDatePicker {
                        DatePicker(
                            "Select target date",
                            selection: $targetDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Progress: \(Int(progress * 100))%")
                            .font(.subheadline)
                        
                        Slider(value: $progress, in: 0...1, step: 0.05)
                            .tint(progress >= 1 ? .green : settings.currentTheme.accentColor)
                        
                        HStack {
                            ForEach([0, 0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                                Button(action: { progress = value }) {
                                    Text("\(Int(value * 100))%")
                                        .font(.caption)
                                        .padding(4)
                                        .frame(minWidth: 30)
                                        .background(progress == value ? settings.currentTheme.accentColor.opacity(0.3) : Color.clear)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: addGoal) {
                        HStack {
                            Spacer()
                            Text("Add Goal")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                    .tint(settings.currentTheme.accentColor)
                }
            }
            .navigationTitle("New \(selectedType.rawValue) Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addGoal() {
        let goal = Goal(
            type: selectedType,
            title: title,
            description: description,
            isCompleted: progress >= 1.0,
            targetDate: targetDate,
            progress: progress
        )
        goalsStore.addGoal(goal)
        presentationMode.wrappedValue.dismiss()
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
    }
}
