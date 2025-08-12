import AppKit
import Foundation
import Supabase

@MainActor
final class SupabaseAuth: ObservableObject {
    static let shared = SupabaseAuth()
    @Published var user: User?
    var isAuthenticated: Bool { user != nil }

    private var client: SupabaseClient
    private var supabaseUrl: String = ""
    private var supabaseKey: String = ""

    init() {
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

    func signInWithGoogle() async throws {
        let oauthURL = try await client.auth.getOAuthSignInURL(
            provider: .google,
            redirectTo: URL(string: "blockerapp://auth-callback")!
        )

        // Open OAuth URL in browser
        await MainActor.run {
            if NSWorkspace.shared.open(oauthURL) {
                NSLog("[blockerapp] OAuth URL opened successfully: \(oauthURL)")
            } else {
                NSLog("[blockerapp] Failed to open OAuth URL")
            }
        }
    }

    func getCurrentUser() async throws -> User {
        let session = try await client.auth.session
        return session.user
    }

 func isUserSignedIn() async -> Bool {
        do {
            let session = try await client.auth.session
                user = session.user
            if let uid = user?.id {
                StatisticsManager.shared.updateUserId(userId:uid)
            }

                return true
          
      
        } catch {
            return false
        }
    }

  func logout() async {
    do {
        try await client.auth.signOut()
        user = nil
        StatisticsManager.shared.updateUserId(userId: nil)
        print("Successfully signed out")
    } catch {
        print("Logout failed:", error)
        // optionally: show an alert or set an error state property
    }
}

}


