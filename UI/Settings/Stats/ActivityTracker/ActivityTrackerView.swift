import SwiftUI

struct ActivityTrackerView: View {
    @ObservedObject var stats = StatisticsManager.shared

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        return cal
    }

    private var weeks: [[Date]] {
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -365, to: today)!

        // Monday before start
        var firstMonday = start
        while calendar.component(.weekday, from: firstMonday) != 2 {
            firstMonday = calendar.date(byAdding: .day, value: -1, to: firstMonday)!
        }

        // Sunday after today
        var lastSunday = today
        while calendar.component(.weekday, from: lastSunday) != 1 {
            lastSunday = calendar.date(byAdding: .day, value: 1, to: lastSunday)!
        }

        // Build weeks
        var result: [[Date]] = []
        var current = firstMonday
        while current <= lastSunday {
            var week: [Date] = []
            for i in 0 ..< 7 {
                if let d = calendar.date(byAdding: .day, value: i, to: current) {
                    week.append(d)
                }
            }
            result.append(week)
            current = calendar.date(byAdding: .day, value: 7, to: current)!
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Focus Activity")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.white)
            Text("Your daily focus sessions over the past year")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 4) {
                    // Month labels row (aligned per day, not per week)
                    // Month labels row
                    HStack(spacing: 4) {
                        ForEach(weeks, id: \.self) { week in
                            if let firstOfMonth = week.first(where: { calendar.component(.day, from: $0) == 1 }) {
                                Text(monthName(for: firstOfMonth))
                                    .font(.custom("Inter-Regular", size: 8))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 18, alignment: .leading)

                            } else {
                                Color.clear.frame(width: 16) // keeps alignment with day columns but invisible
                            }
                        }
                    }

                    // Squares grid
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(weeks, id: \.self) { week in
                            VStack(spacing: 4) {
                                ForEach(week, id: \.self) { day in
                                    let h = stats.hoursPerDay[calendar.startOfDay(for: day)] ?? -1
                                    Rectangle()
                                        .fill(color(for: h))
                                        .frame(width: 16, height: 16)
                                        .cornerRadius(3)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Legend
            HStack {
                Text("Less").font(.caption2).foregroundColor(.white.opacity(0.6))
                HStack(spacing: 3) {
                    ForEach([0.1, 0.2, 0.3, 0.4], id: \.self) { opacity in
                        Rectangle()
                            .fill(Color.white.opacity(opacity))
                            .frame(width: 14, height: 14)
                            .cornerRadius(2)
                    }
                }
                Text("More").font(.caption2).foregroundColor(.white.opacity(0.6))
            }
            .padding(.top, 4)
        }
        .padding(24)
        .glassBackground(cornerRadius: 16)
        
        
    }

    private func monthName(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: date)
    }

    private func color(for hours: Int) -> Color {
        if hours < 0 {
            return Color.white.opacity(0.05)
        } else if hours < 1 {
            return Color.white.opacity(0.1)
        } else if hours < 2 {
            return Color.white.opacity(0.2)
        } else if hours < 3 {
            return Color.white.opacity(0.3)
        } else {
            return Color.white.opacity(0.4)
        }
    }
}
