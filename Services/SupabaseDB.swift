import AppKit
import Foundation
import Supabase
typealias FilterValue = any PostgrestFilterValue

class SupabaseDB {
    static let shared = SupabaseDB()

    private var client: SupabaseClient

    private init() {
        guard let supabaseUrlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String,
              let supabaseUrl = URL(string: supabaseUrlString)
        else {
            fatalError("Missing or invalid Supabase environment variables. Please check your Info.plist file.")
        }

        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
    
    func getClient() -> SupabaseClient {
        return client
    }
    
    // Basic database operations


    func select<T: Decodable>(
        table: String,
        columns: String = "*",
        filters: [String: FilterValue] = [:]
    ) async throws -> [T] {
        var query = client.from(table).select(columns)
        for (key, value) in filters {
            query = query.eq(key, value: value)
        }

       return try await query.execute().value
    }

    
    func insert<T: Codable>(table: String, data: T) async throws {
        try await client.from(table).insert(data).execute().value
    }
    
    func update<U: Encodable>(
        table: String,
        data: U,
        filters: [String: FilterValue]
    ) async throws {
        var q = try await client.from(table).update(data)
        for (k, v) in filters { q = q.eq(k, value: v) }
        _ = try await q.execute()
    }

    
    func delete<T: Decodable>(
        table: String,
        filters: [String: FilterValue]
    ) async throws -> [T] {
        var query = client.from(table).delete()
        for (key, value) in filters {
            query = query.eq(key, value: value)
        }
        return try await query.select().execute().value
    }
}
