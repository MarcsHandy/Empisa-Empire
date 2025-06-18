import SwiftUI
import Foundation

struct StatusRecord: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var postsCreated: Int
    var storiesCreated: Int
    var reelsCreated: Int
    var commentsMade: Int
    var minutesEngaged: Int
    var outreachMessages: Int
}
