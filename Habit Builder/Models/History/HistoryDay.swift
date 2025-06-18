import Foundation

struct HistoryDay: Identifiable, Codable {
    let id: UUID
    let dayNumber: Int
    let title: String
    let essay: String
    let keyPoints: [String]
    let reflectionQuestion: String
    let recommendedReading: String?
    let videoURL: String?
    
    init(id: UUID = UUID(),
         dayNumber: Int,
         title: String,
         essay: String,
         keyPoints: [String],
         reflectionQuestion: String,
         recommendedReading: String? = nil,
         videoURL: String? = nil) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.essay = essay
        self.keyPoints = keyPoints
        self.reflectionQuestion = reflectionQuestion
        self.recommendedReading = recommendedReading
        self.videoURL = videoURL
    }
}
