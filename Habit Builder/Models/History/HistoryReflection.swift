import Foundation

struct HistoryReflection: Identifiable, Codable {
    let id: UUID
    let dayNumber: Int
    let date: Date
    let answer: String
    let notes: String
    
    init(id: UUID = UUID(),
         dayNumber: Int,
         date: Date = Date(),
         answer: String,
         notes: String = "") {
        self.id = id
        self.dayNumber = dayNumber
        self.date = date
        self.answer = answer
        self.notes = notes
    }
}
