import SwiftUI

struct ActivityTrackerView: View {
    @ObservedObject var stats = StatisticsManager.shared
    @State private var hoveredDay: Date? = nil
    @State private var isScrolling: Bool = false

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        return cal
    }

    private var weeks: [[Date]] {
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -365, to: today)!

        var firstMonday = start
        while calendar.component(.weekday, from: firstMonday) != 2 {
            firstMonday = calendar.date(byAdding: .day, value: -1, to: firstMonday)!
        }

        var result: [[Date]] = []
        var current = firstMonday
        while current <= today {
            var week: [Date] = []
            for i in 0 ..< 7 {
                if let d = calendar.date(byAdding: .day, value: i, to: current),
                   d <= today
                {
                    week.append(d)
                }
            }
            result.append(week)
            current = calendar.date(byAdding: .day, value: 7, to: current)!
        }
        return result
    }

    private var legendEntries: [(color: Color, label: String)] {
        [
            (Color.white.opacity(0.05), "0h"),
            (Color.white.opacity(0.1), "<1h"),
            (Color.white.opacity(0.2), "1h+"),
            (Color.white.opacity(0.3), "2h+"),
            (Color.white.opacity(0.4), "3h+"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            scrollableContent
            legend
        }
        .padding(24)
        .glassBackground(cornerRadius: 16)
        .overlay(
            Group {
                if let day = hoveredDay {
                    hoverTooltip(for: day)
                        .padding(.bottom, 12)
                        .padding(.trailing, 12)
                }
            },
            alignment: .bottomTrailing
        )
    }
}

// MARK: - Subviews

extension ActivityTrackerView {
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Focus Activity")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.white)
            Text("Your daily focus sessions over the past year")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    private var scrollableContent: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        monthLabelsRow
                        squaresGrid

                        // invisible marker for scroll offset
                        Color.clear
                            .frame(width: 1, height: 1)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: ScrollOffsetKey.self,
                                        value: geo.frame(in: .named("scroll")).minX
                                    )
                                }
                            )
                    }
                    .padding(.vertical, 4)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { _ in
                isScrolling = true
                hoveredDay = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isScrolling = false
                }
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo("lastWeek", anchor: .trailing)
                }
            }
        }
    }

    private var monthLabelsRow: some View {
        HStack(spacing: 4) {
            ForEach(weeks, id: \.self) { week in
                if let firstOfMonth = week.first(where: { calendar.component(.day, from: $0) == 1 }) {
                    Text(monthName(for: firstOfMonth))
                        .font(.custom("Inter-Regular", size: 8))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 18, alignment: .leading)
                } else {
                    Color.clear.frame(width: 16)
                }
            }
        }
    }

    private var squaresGrid: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(Array(weeks.enumerated()), id: \.element) { wIdx, week in
                VStack(spacing: 4) {
                    ForEach(week, id: \.self) { day in
                        let dayKey = calendar.startOfDay(for: day)
                        let total = stats.hoursPerDay[dayKey]

                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(color(for: total))
                            .frame(width: 16, height: 16)
                            .contentShape(Rectangle())
                            .onHover { hovering in
                                guard !isScrolling else { return }
                                if hovering {
                                    hoveredDay = day
                                } else if hoveredDay == day {
                                    hoveredDay = nil
                                }
                            }
                    }
                }
                .id(wIdx == weeks.count - 1 ? "lastWeek" : nil)
            }
        }
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Legend")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))

            HStack(spacing: 8) {
                ForEach(legendEntries.indices, id: \.self) { idx in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(legendEntries[idx].color)
                            .frame(width: 18, height: 18)
                            .cornerRadius(3)

                        Text(legendEntries[idx].label)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    private func hoverTooltip(for day: Date) -> some View {
        let dayKey = calendar.startOfDay(for: day)
        let total = stats.hoursPerDay[dayKey]

        return VStack(alignment: .trailing, spacing: 2) {
            Text(dateString(for: day))
                .font(.caption)
                .foregroundColor(.white)
            if let total = total {
                Text(total.formatted)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                Text("No sessions")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(8)
        .glassBackground(cornerRadius: 8)
        .cornerRadius(8)
        .padding(12)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.12), value: hoveredDay)
    }
}

// MARK: - Helpers

extension ActivityTrackerView {
    private func monthName(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: date)
    }

    private func dateString(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM yyyy"
        return fmt.string(from: date)
    }

    private func color(for total: DailyTotal?) -> Color {
        guard let total = total else {
            return Color.white.opacity(0.05) // no entry at all
        }

        let hours = total.seconds / 3600
        if total.seconds > 0 && hours < 1 {
            return Color.white.opacity(0.1) // some activity but <1h
        } else if hours < 1 {
            return Color.white.opacity(0.05) // truly empty
        } else if hours < 2 {
            return Color.white.opacity(0.2)
        } else if hours < 3 {
            return Color.white.opacity(0.3)
        } else {
            return Color.white.opacity(0.4)
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
