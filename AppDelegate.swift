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
       let blockerState = AppStateManager.shared.loadBlockerState()
         

            if blockerState?.hardLocked ?? true {
                print("blockerState locked")
                BlockerManager.shared.hardLocked = true
                BlockerManager.shared.remainingTime = blockerState?.remainingTime ?? 0
                BlockerManager.shared.isRunning = blockerState?.isRunning ?? false
                BlockerManager.shared.resumeTimer = true
            }
    }
}
