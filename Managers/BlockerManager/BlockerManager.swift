import AppKit
import SwiftUI

class BlockerManager: ObservableObject {
    static let shared = BlockerManager()
    var blockedApps: [String] = ["com.apple.Safari"] // Example bundle ID

    @Published var isRunning: Bool = false

    @Published var hardLocked: Bool = false

    private var monitorObserver: Any?

    private init() {}

    func toggleBlocker() {
        print("toggleBlocker on blocker manager")
        if isRunning {
            isRunning = false
            stopMonitoring()
            stopWebsiteBlocker()
        } else {
            isRunning = true
            startMonitoring()
            startWebsiteBlocker()
        }
    }

    func toggleHardLocked() {
        hardLocked.toggle()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        print("Starting monitoring")
        killBlockedApps()

        // Listen for app launches
        monitorObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let bundleID = app.bundleIdentifier else { return }

            if self.blockedApps.contains(bundleID) {
                print("Blocked app launched: \(bundleID) — terminating.")
                app.forceTerminate()
            }
        }
    }

    private func stopMonitoring() {
        if let observer = monitorObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            monitorObserver = nil
        }
    }

    // Kill already running blocked apps
    private func killBlockedApps() {
        for app in NSWorkspace.shared.runningApplications {
            if let bundleID = app.bundleIdentifier,
               blockedApps.contains(bundleID)
            {
                print("Terminating running blocked app: \(bundleID)")
                app.forceTerminate()
            }
        }
    }

    func startWebsiteBlocker() {
        WebsiteBlocker.shared.block(domains: ["google.com", "facebook.com", "instagram.com"])
    }

    func stopWebsiteBlocker() {
        WebsiteBlocker.shared.unblock()
    }
}
