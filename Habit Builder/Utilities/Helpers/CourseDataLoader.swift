import SwiftUI
import AVFoundation
import Foundation

class CourseDataLoader {
    static func loadCourses() -> [HistoryCourse] {
        guard let url = Bundle.main.url(forResource: "HistoryCourses", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to locate or load JSON file")
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let wrapper = try decoder.decode(CourseDataWrapper.self, from: data)
            return wrapper.courses
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}
