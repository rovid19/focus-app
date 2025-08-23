import SwiftUI

struct TodaySummary {
    let date: String
    let totalHours: String
    let totalSessions: Int
    let sessionNames: [String]
    let totalFocusTime: Int // in seconds
}

@MainActor
class SocialMediaShareController: ObservableObject {
    @Published var showingSummaryPopup = false
    @Published var todaySummary: TodaySummary?
    
    func createTodaySummary() {
        let summary = generateTodaySummary()
        todaySummary = summary
        showingSummaryPopup = true
    }
    
    private func generateTodaySummary() -> TodaySummary {
        let stats = StatisticsManager.shared.stats
        let today = Calendar.current.startOfDay(for: Date())
        
        // Filter today's stats
        let todayStats = stats.filter { stat in
            guard let createdAt = stat.createdAt else { return false }
            let statDate = Calendar.current.startOfDay(for: createdAt)
            return statDate == today
        }
        
        // Calculate summary data
        let totalSeconds = todayStats.reduce(0) { $0 + $1.time_elapsed }
        let totalSessions = todayStats.count
        let sessionNames = todayStats.map { $0.title }
        let totalHours = StatisticsManager.shared.formatSecondsToHoursAndMinutes(totalSeconds)
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let dateString = dateFormatter.string(from: Date())
        
        return TodaySummary(
            date: dateString,
            totalHours: totalHours,
            totalSessions: totalSessions,
            sessionNames: sessionNames,
            totalFocusTime: totalSeconds
        )
    }
}