import SwiftUI
import Foundation

struct Platform: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let icon: String
}
