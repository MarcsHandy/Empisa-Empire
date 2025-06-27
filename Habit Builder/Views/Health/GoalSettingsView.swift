import SwiftUI
import AVFoundation
import Foundation

struct GoalSettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var waterGoal: Double
    @Binding var sleepGoal: Double
    @Binding var caloriesGoal: Int
    
    @State private var tempWaterGoal: String
    @State private var tempSleepGoal: String
    @State private var tempCaloriesGoal: String
    
    init(waterGoal: Binding<Double>, sleepGoal: Binding<Double>, caloriesGoal: Binding<Int>) {
        self._waterGoal = waterGoal
        self._sleepGoal = sleepGoal
        self._caloriesGoal = caloriesGoal
        self._tempWaterGoal = State(initialValue: String(format: "%.1f", waterGoal.wrappedValue))
        self._tempSleepGoal = State(initialValue: String(format: "%.1f", sleepGoal.wrappedValue))
        self._tempCaloriesGoal = State(initialValue: "\(caloriesGoal.wrappedValue)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Goals")) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        TextField("Water Goal", text: $tempWaterGoal)
                            .keyboardType(.decimalPad)
                        Text(settings.waterUnit.rawValue)
                    }
                    
                    HStack {
                        Image(systemName: "moon.zzz.fill")
                            .foregroundColor(.purple)
                        TextField("Sleep Goal", text: $tempSleepGoal)
                            .keyboardType(.decimalPad)
                        Text("hours")
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        TextField("Calories Goal", text: $tempCaloriesGoal)
                            .keyboardType(.numberPad)
                        Text("kcal")
                    }
                }
                
                Section {
                    Button("Save Goals") {
                        saveGoals()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!goalsAreValid)
                }
            }
            .navigationTitle("Health Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var goalsAreValid: Bool {
        Double(tempWaterGoal) != nil &&
        Double(tempSleepGoal) != nil &&
        Int(tempCaloriesGoal) != nil
    }
    
    private func saveGoals() {
        if let water = Double(tempWaterGoal) {
            waterGoal = water
        }
        if let sleep = Double(tempSleepGoal) {
            sleepGoal = sleep
        }
        if let calories = Int(tempCaloriesGoal) {
            caloriesGoal = calories
        }
        presentationMode.wrappedValue.dismiss()
    }
}
