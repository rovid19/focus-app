
import Combine
import SwiftUI

class HomeController: ObservableObject {
    @Published var whichView: String = "focus"
    @Published var isTimerRunning: Bool = false
    @ObservedObject var router: Router

    init(router: Router) {
        self.router = router
        checkAuth()
    }

    // Home View
    var homeView: HomeView {
        HomeView(controller: self)
    }

    // Focus View
   lazy var focusController = FocusController(homeController: self)
    var focusView: FocusView {
        FocusView(controller: focusController)
    }

    // Stats View
    var statsController = StatsController()
    var statsView: StatsView {
        StatsView(controller: statsController)
    }

    // Blocker View
    var blockerController = BlockerController()
    var blockerView: BlockerView {
        BlockerView(controller: blockerController)
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

    func openSettings() {
        router.changeView(view: .settings)
    }
}
