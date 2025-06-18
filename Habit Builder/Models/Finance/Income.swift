import Foundation
import SwiftUI

struct IncomeRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var amount: Double
    
    init(id: UUID = UUID(), date: Date = Date(), amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}
