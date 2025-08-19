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

@MainActor
final class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    @Published var stats: [Stat] = []
    @Published var totalSeconds: Int = 0
    @Published var totalHours: String = ""
    @Published var isLoading: Bool = true

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
            print("Adding stat to database: \(stat)")
            try await SupabaseDB.shared.insert(table: "Stats", data: stat)
        } catch {
            print("Error adding stat to database: \(error)")
        }
    }

    func getStatsFromDatabase() async {
        print("Getting stats from database")
        do {
            let stats: [Stat] = try await SupabaseDB.shared.select(
                table: "Stats",
                columns: "*",
                filters: ["user_id": userId]
            )
            //print("stats", stats)
            isLoading = false
            self.stats = stats
            totalSeconds = getDailySecondsSummary()
            totalHours = formatSecondsToHoursAndMinutes(totalSeconds)
        } catch {
            print("Error getting stats from database: \(error)")
        }
    }

    func removeStatFromDatabase(stat: Stat) async {
        do {
            let stat: [Stat] = try await SupabaseDB.shared.delete(table: "Stats", filters: ["id": stat.id])
            print("stat", stat)
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

    func formatSecondsToHoursAndMinutes(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            if minutes == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                let minPart = minutes == 1 ? "1 minute" : "\(minutes) minutes"
                return hours == 1
                    ? "1 hour \(minPart)"
                    : "\(hours) hours \(minPart)"
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
}
