import SwiftUI

class StatsController: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var showingCalendar = false
    
    private let calendar = Calendar.current
    
    init() {
        // Set selected date to today by default
        selectedDate = calendar.startOfDay(for: Date())
    }
    
    func getStatsForSelectedDate(from statsSortedByDate: [StatSortedByDate]) -> [Stat] {
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        
        guard let dayStats = statsSortedByDate.first(where: { dayData in
            calendar.isDate(dayData.date, inSameDayAs: selectedDayStart)
        }) else {
            return []
        }
        
        return dayStats.stats
    }
    
    func toggleCalendar() {
        showingCalendar.toggle()
    }
}