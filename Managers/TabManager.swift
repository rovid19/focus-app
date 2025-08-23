import AppKit
import SwiftUI

class TabManager: ObservableObject {
    static let shared = TabManager()

    @Published var tabLimit: Int = 3
    private var timer: DispatchSourceTimer?

    private init() {}

    func startBlocking(limit: Int) {
        NSLog("🚀 [focus-app] startBlocking called with limit: \(limit)")
        tabLimit = limit
        stopBlocking()

        // Run immediately
        enforceLimit(browser: "Safari")
        enforceLimit(browser: "Google Chrome")

        // Then repeat
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let self else { return }
            self.enforceLimit(browser: "Safari")
            self.enforceLimit(browser: "Google Chrome")
        }
        timer?.resume()
    }

    func stopBlocking() {
        timer?.cancel()
        timer = nil
        NSLog("🛑 [focus-app] Tab blocking stopped")
    }

    private func enforceLimit(browser: String) {
        let script = """
        if application "\(browser)" is running then
            tell application "\(browser)"
                if (count of windows) > 0 then
                    set tabCount to count of tabs of window 1
                    if tabCount > \(tabLimit) then
                        close (tabs of window 1 whose index > \(tabLimit))
                    end if
                end if
            end tell
        end if
        """
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if let error = error {
                print("❌ [focus-app] AppleScript error in \(browser): \(error)")
            }
        }
    }
}
