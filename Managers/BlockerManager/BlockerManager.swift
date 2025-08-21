import AppKit
import SwiftUI

struct BlockRow: Encodable {
    let user_id: String
    let BlockedWebsites: [String]
    let BlockedApps: [String]
}



class BlockerManager: ObservableObject {
    static let shared = BlockerManager()
    var blockedApps: [String] = ["com.apple.Safari"] // Example bundle ID
    @Published var isRunning: Bool = false
    @Published var hardLocked: Bool = false
    @Published var remainingTime: Int = 3600
    @Published var blockedWebsites: [String] = []
    var resumeTimer: Bool = false
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
        if hardLocked {
            hardLocked = false
            removeHardLockFlag()
            AppStateManager.shared.saveBlockerState(BlockerState(remainingTime: remainingTime, isRunning: isRunning, hardLocked: hardLocked))
            // Remove Activity Monitor from block list
            blockedApps.removeAll { $0 == "com.apple.ActivityMonitor" }
        } else {
            hardLocked = true
            createHardLockFlag()
            AppStateManager.shared.saveBlockerState(BlockerState(remainingTime: remainingTime, isRunning: isRunning, hardLocked: hardLocked))
            // Add Activity Monitor to block list
            if !blockedApps.contains("com.apple.ActivityMonitor") {
                blockedApps.append("com.apple.ActivityMonitor")
            }
            // Kill Activity Monitor if already running
            killBlockedApps()
        }
    }

    func saveBlockToDatabase() async {
        guard let user = await SupabaseAuth.shared.user else {
            print("No logged-in user")
            return
        }

        let row = BlockRow(
            user_id: user.id.uuidString, // 👈 convert UUID → String
            BlockedWebsites: blockedWebsites,
            BlockedApps: blockedApps
        )

        do {
            try await SupabaseDB.shared.getClient()
                .from("Blocker")
                .upsert(row, onConflict: "user_id")
                .execute()

            print("Blocked domains saved to database: \(blockedWebsites)")
            print("Blocked apps saved to database: \(blockedApps)")
        } catch {
            print("Error saving blocked domains to database: \(error)")
        }
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
        print("Starting website blocker with domains: \(blockedWebsites)")
        WebsiteBlocker.shared.block(domains: blockedWebsites)
    }

    func stopWebsiteBlocker() {
        WebsiteBlocker.shared.unblock()
    }

    private func createHardLockFlag() {
        let flagPath = "/tmp/focus-hardlock-on"
        _ = runShell("touch \(flagPath)")
    }

    private func removeHardLockFlag() {
        let flagPath = "/tmp/focus-hardlock-on"
        _ = runShell("rm -f \(flagPath)")
    }

    @discardableResult
    private func runShell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
