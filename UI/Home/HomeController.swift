
import Combine
import SwiftUI

class HomeController: ObservableObject {
    @Published var whichView: String = "focus"
    
    // Home View
    var homeView: HomeView {
        HomeView(controller: self)
    }

    // Focus View
    var focusController = FocusController()
    var focusView: FocusView {
        FocusView(controller: focusController)
    }

    // Stats View
    var statsController = StatsController()
    var statsView: StatsView {
        StatsView(controller: statsController)
    }

    init() {
        checkAuth()
    }

    func checkAuth() {
        Task {
            let signedIn = await SupabaseAuth.shared.isUserSignedIn()

            if !signedIn {
                print("User is not authenticated")
            } else {
                print("User is authenticated")
            }
        }
    }

    func signIn() {
        Task {
            do {
                try await SupabaseAuth.shared.signInWithGoogle()
            } catch {
                print("Sign-in failed:", error)
            }
        }
    }

    func logout() {
        Task {
            try await SupabaseAuth.shared.logout()
        }
    }

    func switchView(to view: String) {
        whichView = view
    }
}
