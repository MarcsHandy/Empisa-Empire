import SwiftUI
import AVFoundation
import Foundation

class HistoryStore: ObservableObject {
    @Published var courses: [HistoryCourse] = []
    @Published var reflections: [HistoryReflection] = []
    @Published var speechSynthesizer = SpeechSynthesizer()
    
    init() {
        loadData()
        // Load from JSON if no courses exist
        if courses.isEmpty {
            loadCoursesFromJSON()
        }
    }
    
    private func loadCoursesFromJSON() {
        // Load from JSON file instead of sample data
        let loadedCourses = CourseDataLoader.loadCourses()
        
        if loadedCourses.isEmpty {
            // Fallback to sample data if JSON fails
            initializeSampleCourses()
        } else {
            courses = loadedCourses
            saveData()
        }
    }
    
    // Course Management
    func enrollInCourse(courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            courses[index].isEnrolled = true
            courses[index].startDate = Date()
            courses[index].currentDay = 1
            saveData()
        }
    }
    
    func completeCurrentDay(courseId: UUID, reflectionAnswer: String, notes: String = "") {
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseId }),
              courses[courseIndex].isEnrolled,
              courses[courseIndex].currentDay <= courses[courseIndex].durationInDays else {
            return
        }
        
        let currentDay = courses[courseIndex].currentDay
        
        // Add reflection
        let reflection = HistoryReflection(
            dayNumber: currentDay,
            answer: reflectionAnswer,
            notes: notes
        )
        reflections.append(reflection)
        
        // Mark day as completed
        if !courses[courseIndex].completedDays.contains(currentDay) {
            courses[courseIndex].completedDays.append(currentDay)
        }
        
        // Move to next day if not at end
        if currentDay < courses[courseIndex].durationInDays {
            courses[courseIndex].currentDay += 1
        }
        
        saveData()
    }
    
    func getCurrentDayContent(courseId: UUID) -> HistoryDay? {
        guard let course = courses.first(where: { $0.id == courseId }),
              course.isEnrolled,
              course.currentDay <= course.durationInDays,
              let dayContent = course.days.first(where: { $0.dayNumber == course.currentDay }) else {
            return nil
        }
        return dayContent
    }
    
    // Text-to-Speech
    func speak(text: String) {
        speechSynthesizer.speak(text: text)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking()
    }
    
    // Data Persistence
    private func saveData() {
        if let encodedCourses = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encodedCourses, forKey: "historyCourses")
        }
        if let encodedReflections = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(encodedReflections, forKey: "historyReflections")
        }
    }
    
    private func loadData() {
        if let coursesData = UserDefaults.standard.data(forKey: "historyCourses"),
           let decodedCourses = try? JSONDecoder().decode([HistoryCourse].self, from: coursesData) {
            courses = decodedCourses
        }
        if let reflectionsData = UserDefaults.standard.data(forKey: "historyReflections"),
           let decodedReflections = try? JSONDecoder().decode([HistoryReflection].self, from: reflectionsData) {
            reflections = decodedReflections
        }
    }
    
    // Sample Data
    private func initializeSampleCourses() {
        // Create a 30-day African History course
        var africanHistoryDays: [HistoryDay] = []
        
        for day in 1...30 {
            africanHistoryDays.append(HistoryDay(
                dayNumber: day,
                title: "African History Day \(day)",
                essay: "This is a detailed essay about African history for day \(day). It covers important events, figures, and cultural aspects that shaped the continent. The content would be much more detailed in a real implementation, with proper historical research and citations.",
                keyPoints: [
                    "Key point 1 for day \(day)",
                    "Key point 2 for day \(day)",
                    "Key point 3 for day \(day)"
                ],
                reflectionQuestion: "What did you find most interesting about today's lesson?",
                recommendedReading: "Recommended book for day \(day)",
                videoURL: "https://example.com/video/day\(day)"
            ))
        }
        
        let africanHistoryCourse = HistoryCourse(
            title: "30 Days of African History",
            description: "A comprehensive journey through African history, covering ancient civilizations, colonialism, independence movements, and modern developments.",
            durationInDays: 30,
            days: africanHistoryDays
        )
        
        courses = [africanHistoryCourse]
        saveData()
    }
}
