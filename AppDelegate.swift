import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        // Launch as menu bar only
        NSApp.setActivationPolicy(.accessory)
        loadState()
    }

    func application(_: NSApplication, open urls: [URL]) {
        guard let url = urls.first,
              let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
              .queryItems?.first(where: { $0.name == "code" })?.value
        else { return }

        Task {
            do {
                let session = try await SupabaseAuth.shared
                    .getClient()
                    .auth
                    .exchangeCodeForSession(authCode: code)

                SupabaseAuth.shared.user = session.user
                print("Logged in \(SupabaseAuth.shared.user)")
            } catch {
                NSLog("[blockerapp] Exchange failed: \(error)")
            }
        }
    }

    // MARK: - Persistence

    private func loadState() {
        guard let savedData = UserDefaults.standard.data(forKey: "BlockerState"),
              let state = try? JSONDecoder().decode(BlockerState.self, from: savedData)
        else {
            print("No saved BlockerState found")
            return
        }

        if state.hardLocked {
            BlockerManager.shared.remainingTime = state.remainingTime
            BlockerManager.shared.isRunning = state.isRunning
            BlockerManager.shared.hardLocked = state.hardLocked
            BlockerManager.shared.resumeTimer = true

            print("App delegate: hard lock restored — \(state)")
        } else {
            print("App delegate: hard lock was not active")
        }
    }
}
