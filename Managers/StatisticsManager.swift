import SwiftUI

struct Stat: Codable {
    let id: Int? 
    let title: String
    let time_elapsed: Int
    let userId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case time_elapsed
        case userId = "user_id"
    }
}

@MainActor
final class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    @Published var stats: [Stat] = []
    private(set) var userId: UUID?

    func addStat(title: String, time_elapsed: Int) async {
        guard let uid = userId else {
            print("❌ Cannot add stat — no user logged in")
            return
        }

        let stat = Stat(id: nil, title: title, time_elapsed: time_elapsed, userId: uid)
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
            print("stats", stats)

            self.stats = stats

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
}
