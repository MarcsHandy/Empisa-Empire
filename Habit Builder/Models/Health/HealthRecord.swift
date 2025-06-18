import SwiftUI
import Foundation

struct HealthRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var waterIntake: Double // in liters
    var sleepHours: Double
    var caloriesConsumed: Int
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         waterIntake: Double = 0,
         sleepHours: Double = 0,
         caloriesConsumed: Int = 0) {
        self.id = id
        self.date = date
        self.waterIntake = waterIntake
        self.sleepHours = sleepHours
        self.caloriesConsumed = caloriesConsumed
    }
}
