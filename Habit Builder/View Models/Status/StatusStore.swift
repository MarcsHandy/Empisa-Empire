import SwiftUI
import AVFoundation
import Foundation

class StatusStore: ObservableObject {
    @Published var platforms: [Platform] = []
    @Published var dailyMetrics: [DailyMetric] = []
    
    init() {
        loadData()
        if platforms.isEmpty {
            // Initialize with common platforms if empty
            platforms = [
                Platform(name: "Instagram", icon: "camera"),
                Platform(name: "Twitter", icon: "bird"),
                Platform(name: "TikTok", icon: "music.note"),
                Platform(name: "YouTube", icon: "play.rectangle"),
                Platform(name: "LinkedIn", icon: "briefcase")
            ]
            saveData()
        }
    }
    
    // Platform management (permanent)
    func addPlatform(name: String, icon: String) {
        guard platforms.count < 5 else { return }
        let newPlatform = Platform(name: name, icon: icon)
        platforms.append(newPlatform)
        saveData()
    }
    
    // Daily metrics (reset each day)
    func incrementMetric(for platformId: UUID, metric: MetricType) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Find or create today's record
        if let index = dailyMetrics.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyMetrics[index].increment(metric: metric, platformId: platformId)
        } else {
            var newMetric = DailyMetric(date: today)
            newMetric.increment(metric: metric, platformId: platformId)
            dailyMetrics.append(newMetric)
        }
        
        saveData()
    }
    
    func getTodayMetrics() -> DailyMetric {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyMetrics.first { Calendar.current.isDate($0.date, inSameDayAs: today) } ?? DailyMetric(date: today)
    }
    
    // Data persistence
    private func saveData() {
        let encoder = JSONEncoder()
        if let encodedPlatforms = try? encoder.encode(platforms),
           let encodedMetrics = try? encoder.encode(dailyMetrics) {
            UserDefaults.standard.set(encodedPlatforms, forKey: "platforms")
            UserDefaults.standard.set(encodedMetrics, forKey: "dailyMetrics")
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        if let platformsData = UserDefaults.standard.data(forKey: "platforms"),
           let decodedPlatforms = try? decoder.decode([Platform].self, from: platformsData) {
            platforms = decodedPlatforms
        }
        if let metricsData = UserDefaults.standard.data(forKey: "dailyMetrics"),
           let decodedMetrics = try? decoder.decode([DailyMetric].self, from: metricsData) {
            dailyMetrics = decodedMetrics
        }
    }
}

struct DailyMetric: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var posts: [UUID: Int] = [:] // Platform ID: Count
    var comments: [UUID: Int] = [:] // Platform ID: Count
    var minutes: [UUID: Int] = [:] // Platform ID: Count
    
    mutating func increment(metric: MetricType, platformId: UUID) {
        switch metric {
        case .post:
            posts[platformId] = (posts[platformId] ?? 0) + 1
        case .comment:
            comments[platformId] = (comments[platformId] ?? 0) + 1
        case .minute:
            minutes[platformId] = (minutes[platformId] ?? 0) + 1
        }
    }
    
    func count(for metric: MetricType, platformId: UUID) -> Int {
        switch metric {
        case .post: return posts[platformId] ?? 0
        case .comment: return comments[platformId] ?? 0
        case .minute: return minutes[platformId] ?? 0
        }
    }
}

enum MetricType {
    case post, comment, minute
}
