import SwiftUI
import AVFoundation
import Foundation

struct HealthView: View {    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var healthStore: HealthStore
    @State private var showingAddHealth = false
    @State private var showingUnitSettings = false
    
    // States for individual metric editing
    @State private var showingEditWater = false
    @State private var showingEditSleep = false
    @State private var showingEditCalories = false
    @State private var tempWaterValue = ""
    @State private var tempSleepValue = ""
    @State private var tempCaloriesValue = ""
    
    private var todaysRecord: HealthRecord {
        healthStore.todaysRecord()
    }
    
    private var weeklyAverages: (water: Double, sleep: Double, calories: Int) {
        healthStore.weeklyAverage()
    }
    
    // Computed properties for water display
    private var waterDisplayValue: String {
        let convertedValue = settings.waterUnit == .liters ?
            todaysRecord.waterIntake :
            todaysRecord.waterIntake * 33.814
        return String(format: "%.1f %@", convertedValue, settings.waterUnit.rawValue)
    }

    private var waterDisplayGoal: String {
        let baseGoal = 2.5 // 2.5 liters is the base goal
        let convertedGoal = settings.waterUnit == .liters ?
            baseGoal :
            baseGoal * 33.814
        return String(format: "%.1f %@", convertedGoal, settings.waterUnit.rawValue)
    }

    private var waterProgress: Double {
        let baseGoal = 2.5
        return todaysRecord.waterIntake / baseGoal
    }

    private var avgWaterDisplayValue: String {
        let convertedValue = settings.waterUnit == .liters ?
            weeklyAverages.water :
            weeklyAverages.water * 33.814
        return String(format: "%.1f %@", convertedValue, settings.waterUnit.rawValue)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's Summary
                        VStack(spacing: 16) {
                            HStack {
                                Text("Today's Health")
                                    .font(.title2.bold())
                                    .foregroundColor(settings.currentTheme.textColor)
                                
                                Spacer()
                                
                                Button(action: { showingUnitSettings = true }) {
                                    Image(systemName: "gear")
                                        .foregroundColor(settings.currentTheme.accentColor)
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                HealthMetricCard(
                                    title: "Water",
                                    value: waterDisplayValue,
                                    goal: waterDisplayGoal,
                                    progress: waterProgress,
                                    color: .blue
                                )
                                .onTapGesture {
                                    showingEditWater = true
                                    tempWaterValue = String(format: "%.1f", healthStore.todaysRecord().waterIntake)
                                }
                                .healthMetricCardEditModifier(
                                    isPresented: $showingEditWater,
                                    title: "Water Intake",
                                    value: $tempWaterValue,
                                    healthStore: healthStore
                                )
                                
                                HealthMetricCard(
                                    title: "Sleep",
                                    value: String(format: "%.1f hrs", todaysRecord.sleepHours),
                                    goal: "8 hrs",
                                    progress: todaysRecord.sleepHours / 8,
                                    color: .purple
                                )
                                .onTapGesture {
                                    showingEditSleep = true
                                    tempSleepValue = String(format: "%.1f", healthStore.todaysRecord().sleepHours)
                                }
                                .healthMetricCardEditModifier(
                                    isPresented: $showingEditSleep,
                                    title: "Sleep Hours",
                                    value: $tempSleepValue,
                                    healthStore: healthStore
                                )
                            }
                            .padding(.horizontal)
                                .healthMetricCardEditModifier(
                                    isPresented: $showingEditSleep,
                                    title: "Sleep Hours",
                                    value: $tempSleepValue,
                                    healthStore: healthStore
                                )
                                .onAppear {
                                    tempSleepValue = String(format: "%.1f", healthStore.todaysRecord().sleepHours)
                                }
                            }
                            .padding(.horizontal)
                            
                        HealthMetricCard(
                            title: "Calories",
                            value: "\(healthStore.todaysRecord().caloriesConsumed)",
                            goal: "2000 kcal",
                            progress: Double(healthStore.todaysRecord().caloriesConsumed) / 2000,
                            color: .orange
                        )
                        .onTapGesture {
                            showingEditCalories = true
                            tempCaloriesValue = "\(healthStore.todaysRecord().caloriesConsumed)"
                        }
                        .healthMetricCardEditModifier(
                            isPresented: $showingEditCalories,
                            title: "Calories Consumed",
                            value: $tempCaloriesValue,
                            healthStore: healthStore
                        )
                            .padding(.horizontal)
                        }
                        
                        // Weekly Averages
                    VStack(spacing: 16) {
                        Text("Weekly Averages")
                            .font(.title2.bold())
                            .foregroundColor(settings.currentTheme.textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            let averages = healthStore.weeklyAverage()
                            
                            HStack(spacing: 16) {
                                HealthMetricCard(
                                    title: "Avg Water",
                                    value: avgWaterDisplayValue,
                                    goal: waterDisplayGoal,
                                    progress: weeklyAverages.water / 2.5,
                                    color: .blue
                                )
                                
                                HealthMetricCard(
                                    title: "Avg Sleep",
                                    value: String(format: "%.1f hrs", averages.sleep),
                                    goal: "8 hrs",
                                    progress: averages.sleep / 8,
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                            
                            HealthMetricCard(
                                title: "Avg Calories",
                                value: "\(averages.calories)",
                                goal: "2000 kcal",
                                progress: Double(averages.calories) / 2000,
                                color: .orange
                            )
                            .padding(.horizontal)
                        }
                        
                        // Recent Records
                        VStack(alignment: .leading) {
                            Text("Recent Records")
                                .font(.title2.bold())
                                .foregroundColor(settings.currentTheme.textColor)
                                .padding(.horizontal)
                            
                            ForEach(healthStore.records.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                HealthRecordRow(record: record)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.2) :
                                                settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.1) :
                                                Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .shadow(color: settings.currentTheme.textColor.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Health Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddHealth = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(settings.currentTheme.accentColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddHealth) {
                    AddHealthView(healthStore: healthStore)
                }
                .sheet(isPresented: $showingUnitSettings) {
                    WaterUnitSettingsView()
                }
            }
        .navigationViewStyle(.stack)
        }
    }


struct WaterUnitSettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Water Measurement Unit")) {
                    Picker("Unit", selection: $settings.waterUnit) {
                        ForEach(SettingsStore.WaterUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Units")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct EditSingleHealthView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var healthStore: HealthStore
    let title: String
    @Binding var value: String
    var date: Date
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Edit \(title)").foregroundColor(settings.currentTheme.accentColor)) {
                        DatePicker("Date", selection: .constant(date), displayedComponents: .date)
                            .disabled(true) // Don't allow date change in this view
                        
                        HStack {
                            Image(systemName: iconForTitle(title))
                                .foregroundColor(colorForTitle(title))
                            TextField(title, text: $value)
                                .keyboardType(keyboardTypeForTitle(title))
                        }
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
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Edit \(title)")
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
    
    private func iconForTitle(_ title: String) -> String {
        if title.contains("Water") { return "drop.fill" }
        if title.contains("Sleep") { return "moon.zzz.fill" }
        return "flame.fill"
    }
    
    private func colorForTitle(_ title: String) -> Color {
        if title.contains("Water") { return .blue }
        if title.contains("Sleep") { return .purple }
        return .orange
    }
    
    private func keyboardTypeForTitle(_ title: String) -> UIKeyboardType {
        if title.contains("Calories") { return .numberPad }
        return .decimalPad
    }
    
    private func saveChanges() {
        guard let newValue = Double(value) else { return }
        
        var record = healthStore.recordForDate(date) ?? HealthRecord(
            date: date,
            waterIntake: 0,
            sleepHours: 0,
            caloriesConsumed: 0
        )
        
        if title.contains("Water") {
            // Convert to liters if the input was in another unit
            let settings = SettingsStore()
            record.waterIntake = settings.waterUnit == .liters ? newValue : newValue / 33.814
        } else if title.contains("Sleep") {
            record.sleepHours = newValue
        } else {
            record.caloriesConsumed = Int(newValue)
        }
        
        healthStore.updateRecord(record)
        presentationMode.wrappedValue.dismiss()
    }
}

struct HealthMetricCard: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let value: String
    let goal: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text(value)
                    .font(.body.bold())
                    .foregroundColor(settings.currentTheme.textColor)
            }
            
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            HStack {
                Text("Goal: \(goal)")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(settings.currentTheme.textColor)
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor == .black ? Color.gray.opacity(0.1) :
                    settings.currentTheme.backgroundColor == .darkPurple ? Color.neonBlue.opacity(0.05) :
                    Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(settings.currentTheme.textColor.opacity(0.1), lineWidth: 1)
        )
    }
}

struct HealthRecordRow: View {
    @EnvironmentObject var settings: SettingsStore
    let record: HealthRecord
    
    private var waterDisplayValue: String {
        String(format: "%.1f %@",
              record.waterIntake.converted(to: settings.waterUnit),
              settings.waterUnit.rawValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.date, format: .dateTime.day().month().year())
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            HStack {
                HealthMetricPill(
                    value: waterDisplayValue,
                    label: "Water",
                    color: .blue
                )
                HealthMetricPill(
                    value: String(format: "%.1f hrs", record.sleepHours),
                    label: "Sleep",
                    color: .purple
                )
                HealthMetricPill(
                    value: "\(record.caloriesConsumed)",
                    label: "Calories",
                    color: .orange
                )
            }
        }
    }
}

struct HealthMetricPill: View {
    @EnvironmentObject var settings: SettingsStore
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(settings.currentTheme.textColor)
            Text(label)
                .font(.caption2)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
        }
        .padding(8)
        .background(color.opacity(0.2))
        .cornerRadius(20)
    }
}

struct AddHealthView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var healthStore: HealthStore
    @State private var waterIntake = ""
    @State private var sleepHours = ""
    @State private var caloriesConsumed = ""
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                settings.currentTheme.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Health Details").foregroundColor(settings.currentTheme.accentColor)) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .accentColor(settings.currentTheme.accentColor)
                        
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            TextField("Water (\(settings.waterUnit.rawValue))", text: $waterIntake)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Image(systemName: "moon.zzz.fill")
                                .foregroundColor(.purple)
                            TextField("Sleep (hours)", text: $sleepHours)
                                .keyboardType(.decimalPad)
                        }
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            TextField("Calories", text: $caloriesConsumed)
                                .keyboardType(.numberPad)
                        }
                    }
                    .listRowBackground(settings.currentTheme.backgroundColor.opacity(0.8))
                    
                    Section {
                        Button(action: {
                            if let water = Double(waterIntake),
                               let sleep = Double(sleepHours),
                               let calories = Int(caloriesConsumed) {
                                healthStore.addRecord(water: water, sleep: sleep, calories: calories, date: date)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Add Health Data")
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
                        .disabled(waterIntake.isEmpty || sleepHours.isEmpty || caloriesConsumed.isEmpty)
                    }
                    .listRowBackground(Color.clear)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationTitle("Add Health Data")
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
