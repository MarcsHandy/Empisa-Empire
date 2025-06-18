import Foundation
import SwiftUI

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    var isRecurring: Bool
    var recurrence: Recurrence?
    
    enum ExpenseCategory: String, CaseIterable, Codable {
        case housing = "Housing"
        case food = "Food"
        case transportation = "Transportation"
        case entertainment = "Entertainment"
        case utilities = "Utilities"
        case health = "Health"
        case shopping = "Shopping"
        case other = "Other"
    }
    
    enum Recurrence: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
}
