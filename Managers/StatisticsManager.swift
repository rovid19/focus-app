import SwiftUI

struct Stat: Codable, Identifiable, Equatable {
    let id: Int?
    let title: String
    let time_elapsed: Int
    let userId: UUID
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case time_elapsed
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct FocusSession {
    let title: String
    let time_elapsed: Int
}

struct SocialMediaSummary {
    let focusTime: String
    let focusSessions: [FocusSession]
    let currentStreak: Int
    let currentDate: Date = .init()
}

struct DailyTotal {
    let seconds: Int
    let formatted: String
}

struct StatSortedByDate {
    let date: Date
    let stats: [Stat]
}

@MainActor
final class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    @Published var stats: [Stat] = []
    @Published var statsSortedByDate: [StatSortedByDate] = []
    @Published var totalSeconds: Int = 0
    @Published var totalHours: String = ""
    @Published var isLoading: Bool = true
    @Published var hoursPerDay: [Date: DailyTotal] = [:]
    var lastUpdated: Date?

    private(set) var userId: UUID?

    func addStat(title: String, time_elapsed: Int) async {
        guard let uid = userId else {
            print("❌ Cannot add stat — no user logged in")
            return
        }

        let stat = Stat(id: nil, title: title, time_elapsed: time_elapsed, userId: uid, createdAt: nil)
        stats.append(stat)
        await addStatToDatabase(stat: stat)
    }

    func addStatToDatabase(stat: Stat) async {
        do {
            try await SupabaseDB.shared.insert(table: "Stats", data: stat)
            await getStatsFromDatabase()
        } catch {
            print("Error adding stat to database: \(error)")
        }
    }

    func getStatsFromDatabase() async {
        do {
            let stats: [Stat] = try await SupabaseDB.shared.select(
                table: "Stats",
                columns: "*",
                filters: ["user_id": userId]
            )
            isLoading = false
            self.stats = stats
            totalSeconds = getDailySecondsSummary()
            totalHours = formatSecondsToHoursAndMinutes(totalSeconds)
            populateHoursPerDay()
            statsSortedByDate = getStatsPerDay(from: stats)
            print("statsSortedByDate", statsSortedByDate)
            lastUpdated = Date()
        } catch {
            print("Error getting stats from database: \(error)")
        }
    }

    func removeStatFromDatabase(stat: Stat) async {
        do {
            let stat: [Stat] = try await SupabaseDB.shared.delete(table: "Stats", filters: ["id": stat.id])
        } catch {
            print("Error removing stat from database: \(error)")
        }
    }

    func renameStat(stat: Stat, newTitle: String) async {
        do {
            try await SupabaseDB.shared.update(table: "Stats", data: ["title": newTitle], filters: ["id": stat.id])

        } catch {
            print("Error renaming stat in database: \(error)")
        }
    }

    func updateUserId(userId: UUID?) {
        self.userId = userId
    }

    func formatSecondsToHoursAndMinutes(_ seconds: Int, breakValue: Bool = false) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            if minutes == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                let minPart = minutes == 1 ? "1 minute" : "\(minutes) minutes"
                return hours == 1
                    ? (breakValue ? "1 hour \n\(minPart)" : "1 hour \(minPart)")
                    : (breakValue ? "\(hours) hours \n\(minPart)" : "\(hours) hours \(minPart)")
            }
        } else {
            return minutes == 1 ? "1 minute" : "\(minutes) minutes"
        }
    }

    private func getDailySecondsSummary() -> Int {
        let totalSeconds = stats.reduce(0) { totalSum, stat in
            guard let createdAt = stat.createdAt else { return totalSum }
            let calendar = Calendar.current
            let statDate = calendar.startOfDay(for: createdAt)
            let today = calendar.startOfDay(for: Date())
            if statDate == today {
                return totalSum + stat.time_elapsed
            }
            return totalSum
        }

        return totalSeconds
    }

    func populateHoursPerDay() {
        var dailyTotals: [Date: Int] = [:]
        let calendar = Calendar.current

        for stat in stats {
            guard let createdAt = stat.createdAt else { continue }
            let day = calendar.startOfDay(for: createdAt)

            // accumulate seconds
            dailyTotals[day, default: 0] += stat.time_elapsed
        }

        // build dictionary with both values
        hoursPerDay = dailyTotals.mapValues { seconds in
            DailyTotal(
                seconds: seconds,
                formatted: formatSecondsToHoursAndMinutes(seconds)
            )
        }
    }

    func getStatsPerDay(from stats: [Stat]) -> [StatSortedByDate] {
        let calendar = Calendar.current

        // 1. Group stats by startOfDay
        let grouped = Dictionary(grouping: stats) { stat in
            calendar.startOfDay(for: stat.createdAt ?? Date())
        }

        // 2. Sort days by date descending (latest first)
        let sorted = grouped.keys.sorted(by: >).map { date in
            // Also sort each day's stats by createdAt descending
            let dayStats = (grouped[date] ?? []).sorted {
                ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
            }
            return StatSortedByDate(date: date, stats: dayStats)
        }

        return sorted
    }

    func getCurrentStreak(from stats: [Stat]) -> [StatSortedByDate] {
        let statsPerDay = getStatsPerDay(from: stats)
        print("statsPerDay", statsPerDay)

        // 3. Go from latest backwards, filter only days with ≥ 1h
        let filtered = statsPerDay
            .reversed()
            .filter { day in
                let totalSeconds = day.stats.map { $0.time_elapsed }.reduce(0, +)
                return totalSeconds >= 3600
            }

        return filtered
    }

    func generateSocialMediaSummary() -> SocialMediaSummary {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Total focus time for today
        let focusTime = formatSecondsToHoursAndMinutes(getDailySecondsSummary(), breakValue: true)

        // Take today's stats and convert them into [FocusSession]
        let todaySessions: [FocusSession] = stats.compactMap { stat in
            if let createdAt = stat.createdAt,
               calendar.startOfDay(for: createdAt) == today
            {
                return FocusSession(title: stat.title, time_elapsed: stat.time_elapsed)
            }
            return nil
        }

        let currentStreak = getCurrentStreak(from: stats).count

        return SocialMediaSummary(
            focusTime: focusTime,
            focusSessions: todaySessions,
            currentStreak: currentStreak
        )
    }

    func getStatsFromDatabaseIfNeeded() async {
        print("getStatsFromDatabaseIfNeeded")
        let now = Date()

        if let last = lastUpdated {
            let timeSinceLastUpdate = now.timeIntervalSince(last)
            guard timeSinceLastUpdate > 5 else {
                print("Skipping fetch — last updated less than 1 hour ago")
                return
            }
        }

        await getStatsFromDatabase()
        lastUpdated = now
    }
}
