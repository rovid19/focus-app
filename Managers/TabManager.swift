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
        let script: String

        if browser == "Safari" {
            script = """
            tell application "Safari"
                repeat with w in windows
                    set tabCount to (count of tabs of w)
                    if tabCount > \(tabLimit) then
                        repeat with i from tabCount to (\(tabLimit) + 1) by -1
                            close tab i of w
                        end repeat
                    end if
                end repeat
            end tell
            """
        } else {
            script = """
            tell application "Google Chrome"
                repeat with w in windows
                    set tabCount to (count of tabs of w)
                    if tabCount > \(tabLimit) then
                        repeat with i from tabCount to (\(tabLimit) + 1) by -1
                            close tab i of w
                        end repeat
                    end if
                end repeat
            end tell
            """
        }

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if let error = error {
                NSLog("❌ [focus-app] AppleScript error in \(browser): \(error)")
            } else {
                NSLog("✅ [focus-app] Enforced tab limit in \(browser)")
            }
        }
    }
}
