import SwiftUI
import AVFoundation
import Foundation

struct HistoryView: View {    @EnvironmentObject var settings: SettingsStore
    @StateObject private var historyStore = HistoryStore()
    @State private var selectedCourse: HistoryCourse? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Course Progress
                    if let currentCourse = historyStore.courses.first(where: { $0.isEnrolled }) {
                        currentCourseView(course: currentCourse)
                    }
                    
                    // Available Courses
                    availableCoursesSection
                }
                .padding()
            }
            .navigationTitle("History Learning")
            .sheet(item: $selectedCourse) { course in
                CourseDetailView(historyStore: historyStore, course: course)
                    .environmentObject(settings)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func currentCourseView(course: HistoryCourse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Course")
                    .font(.title2.bold())
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text("Day \(course.currentDay) of \(course.durationInDays)")
                    .font(.subheadline)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Text(course.title)
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
            
            ProgressView(value: Double(course.currentDay), total: Double(course.durationInDays))
                .tint(settings.currentTheme.accentColor)
            
            if let dayContent = historyStore.getCurrentDayContent(courseId: course.id) {
                NavigationLink {
                    DayContentView(
                        historyStore: historyStore,
                        day: dayContent,
                        courseId: course.id  // Pass the course ID
                    )
                    .environmentObject(settings)
                } label: {
                    Text("Continue to Day \(dayContent.dayNumber): \(dayContent.title)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(settings.currentTheme.accentColor)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var availableCoursesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Courses")
                .font(.title2.bold())
                .foregroundColor(settings.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(historyStore.courses.filter { !$0.isEnrolled }) { course in
                CourseCard(course: course) {
                    selectedCourse = course
                }
            }
        }
    }
}
    
struct CourseCard: View {
    @EnvironmentObject var settings: SettingsStore
    let course: HistoryCourse
    var action: () -> Void  // Add this line
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(settings.currentTheme.accentColor)
                Text(course.title)
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                Spacer()
                Text("\(course.durationInDays) days")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
            }
            
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(settings.currentTheme.textColor.opacity(0.8))
                .lineLimit(2)
            
            HStack {
                Spacer()
                Text("Tap to learn more")
                    .font(.caption)
                    .foregroundColor(settings.currentTheme.accentColor)
            }
        }
        .padding()
        .background(settings.currentTheme.backgroundColor.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(settings.currentTheme.backgroundColor.opacity(0.3), lineWidth: 1)
        )
        .contentShape(Rectangle())  // Make entire card tappable
        .onTapGesture(perform: action)  // Use the passed action
    }
}

struct CourseDetailView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var historyStore: HistoryStore
    let course: HistoryCourse
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(course.title)
                        .font(.title.bold())
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Text(course.description)
                        .font(.body)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Course Details")
                            .font(.headline)
                            .foregroundColor(settings.currentTheme.textColor)
                        
                        DetailRow(icon: "calendar", text: "\(course.durationInDays) days")
                        DetailRow(icon: "book", text: "Daily essays and readings")
                        DetailRow(icon: "questionmark.circle", text: "Reflection questions")
                        DetailRow(icon: "checkmark.circle", text: "Track your progress")
                    }
                    .padding()
                    .background(settings.currentTheme.backgroundColor.opacity(0.1))
                    .cornerRadius(10)
                    
                    if !course.isEnrolled {
                        Button(action: {
                            historyStore.enrollInCourse(courseId: course.id)
                            dismiss()
                        }) {
                            Text("Enroll in Course")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(settings.currentTheme.accentColor)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Course Details", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(settings.currentTheme.accentColor)
                }
            }
        }
    }
}

struct DetailRow: View {
    @EnvironmentObject var settings: SettingsStore
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(settings.currentTheme.accentColor)
                .frame(width: 30)
            Text(text)
                .foregroundColor(settings.currentTheme.textColor)
            Spacer()
        }
    }
}

struct DayContentView: View {
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var historyStore: HistoryStore
    let day: HistoryDay
    let courseId: UUID
    @State private var showingReflectionSheet = false
    
    @State private var isSpeaking = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Day \(day.dayNumber)")
                        .font(.title.bold())
                        .foregroundColor(settings.currentTheme.textColor)
                    Spacer()
                    
                    Button(action: toggleSpeech) {
                        Image(systemName: isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                            .foregroundColor(settings.currentTheme.accentColor)
                    }
                }
                
                Text(day.title)
                    .font(.title2)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Divider()
                
                Text("Today's Essay")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Text(day.essay)
                    .font(.body)
                    .foregroundColor(settings.currentTheme.textColor)
                
                Divider()
                
                Text("Key Points")
                    .font(.headline)
                    .foregroundColor(settings.currentTheme.textColor)
                
                ForEach(day.keyPoints, id: \.self) { point in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(settings.currentTheme.accentColor)
                            .padding(.top, 6)
                        Text(point)
                            .font(.body)
                            .foregroundColor(settings.currentTheme.textColor)
                    }
                }
                
                if let reading = day.recommendedReading {
                    Divider()
                    
                    Text("Recommended Reading")
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Text(reading)
                        .font(.body)
                        .foregroundColor(settings.currentTheme.textColor)
                }
                
                if let videoURL = day.videoURL, let url = URL(string: videoURL) {
                    Divider()
                    
                    Text("Supplementary Video")
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Watch Video")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                }
                
                Button(action: onComplete) {
                    Text("Complete Day")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(settings.currentTheme.accentColor)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Day \(day.dayNumber)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Complete Day") {
                            showingReflectionSheet = true
                        }
                    }
                }
                .sheet(isPresented: $showingReflectionSheet) {
                    ReflectionView(
                        question: day.reflectionQuestion,
                        answer: .constant(""),
                        notes: .constant(""),
                        onSubmit: {
                            historyStore.completeCurrentDay(
                                courseId: courseId,
                                reflectionAnswer: "Sample answer", // Replace with real data
                                notes: "Sample notes" // Replace with real data
                            )
                            showingReflectionSheet = false
                        }
                    )
                    .environmentObject(settings)
                }
            }
        
    
    private func toggleSpeech() {
        if isSpeaking {
            historyStore.stopSpeaking()
        } else {
            historyStore.speak(text: "\(day.title). \(day.essay)")
        }
        isSpeaking.toggle()
    }
    
    private func onComplete() {
        showingReflectionSheet = true
    }
}

struct ReflectionView: View {
    @EnvironmentObject var settings: SettingsStore
    let question: String
    @Binding var answer: String
    @Binding var notes: String
    let onSubmit: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reflection Question").foregroundColor(settings.currentTheme.accentColor)) {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(settings.currentTheme.textColor)
                    
                    TextField("Your answer", text: $answer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Additional Notes").foregroundColor(settings.currentTheme.accentColor)) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(settings.currentTheme.backgroundColor.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Section {
                    Button(action: onSubmit) {
                        HStack {
                            Spacer()
                            Text("Submit Reflection")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(answer.isEmpty)
                    .tint(settings.currentTheme.accentColor)
                }
            }
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onSubmit() // Still submit but with empty values if user cancels
                    }
                }
            }
        }
    }
}

struct CourseDataWrapper: Codable {
    let courses: [HistoryCourse]
}
