import SwiftUI
import AVFoundation
import Foundation

struct GoalListView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var goalsStore: GoalsStore
    var goals: [Goal]
    @Binding var editingGoal: Goal?
    
    var body: some View {
        List {
            ForEach(goals) { goal in
                GoalCard(goal: goal)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            goalsStore.deleteGoal(goal)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            editingGoal = goal
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                        
                        Button {
                            goalsStore.toggleGoalCompletion(goal)
                        } label: {
                            Label(goal.isCompleted ? "Mark Incomplete" : "Complete",
                                  systemImage: goal.isCompleted ? "arrow.uturn.backward" : "checkmark")
                        }
                        .tint(goal.isCompleted ? .orange : .green)
                    }
                    .onTapGesture {
                        editingGoal = goal
                    }
            }
        }
        .listStyle(.plain)
    }
}
