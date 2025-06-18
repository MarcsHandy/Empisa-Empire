import SwiftUI
import AVFoundation
import Foundation

struct GoalFilterView: View {
    @EnvironmentObject var settings: SettingsStore
    @Binding var searchText: String
    @Binding var selectedGoalType: GoalType
    @Binding var showingCompleted: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            SearchBar(text: $searchText, placeholder: "Search goals")
            
            HStack {
                Picker("Goal Type", selection: $selectedGoalType) {
                    ForEach(GoalType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: { showingCompleted.toggle() }) {
                    Image(systemName: showingCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundColor(showingCompleted ? settings.currentTheme.accentColor : settings.currentTheme.textColor)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .background(settings.currentTheme.backgroundColor.opacity(0.8))
    }
}
