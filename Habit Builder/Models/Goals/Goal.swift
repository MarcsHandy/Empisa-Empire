import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    let type: GoalType
    var title: String
    var description: String
    var isCompleted: Bool
    var targetDate: Date
    var progress: Double // 0.0 to 1.0
    
    init(id: UUID = UUID(),
         type: GoalType,
         title: String,
         description: String = "",
         isCompleted: Bool = false,
         targetDate: Date = Date(),
         progress: Double = 0.0) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.targetDate = targetDate
        self.progress = progress
    }
}
