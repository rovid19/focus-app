
import Combine
import SwiftUI

class HomeController: ObservableObject {
    // Home View
    var homeView: HomeView {
        HomeView(controller: self)
    }

    // Focus View
    var focusController = FocusController()
    var focusView: FocusView {
        FocusView(controller: focusController)
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
}
