import AppKit
import SwiftUI

struct BlockRow: Codable {
    let user_id: String
    let BlockedWebsites: [String]
    let BlockedApps: [String]

    enum CodingKeys: String, CodingKey {
        case user_id
        case BlockedWebsites = "blocked_websites"
        case BlockedApps = "blocked_apps"
    }
}

struct ScheduledBlockCodableRow: Codable {
    let user_id: String
    let scheduledBlocks: [ScheduledBlock]?

    enum CodingKeys: String, CodingKey {
        case user_id
        case scheduledBlocks = "scheduled_blocks"
    }
}

struct BlockerTableData: Codable {  
    let user_id: String
    let blocked_websites: [String]
    let blocked_apps: [String]
    let scheduled_blocks: [ScheduledBlock]?
}


class BlockerManager: ObservableObject {
    static let shared = BlockerManager()
    var blockedApps: [String] = ["com.apple.Safari"] // Example bundle ID
    @Published var blockedAppsList: [BlockedApp] = []
    @Published var isRunning: Bool = false
    @Published var hardLocked: Bool = false
    @Published var remainingTime: Int = 3600
    @Published var blockedWebsites: [String] = []
    var scheduledBlocks: [ScheduledBlock]? = []
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
            try await SupabaseDB.shared.upsert(table: "Blocker", data: row)
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

    @MainActor
    func addBlockToDatabase(_ newBlock: ScheduledBlock) async {
        scheduledBlocks?.append(newBlock)
        guard let user = SupabaseAuth.shared.user else {
            print("No logged-in user")
            return
        }
        let row = ScheduledBlockCodableRow(
            user_id: user.id.uuidString,
            scheduledBlocks: scheduledBlocks
        )

        do {
            try await SupabaseDB.shared.upsert(table: "Blocker", data: row)
        } catch {
            print("Error saving scheduled blocks to database: \(error)")
        }
    }
    
    @MainActor
    func getBlockerTable() async {
        guard let user = SupabaseAuth.shared.user else {
            print("No logged-in user")
            return
        }
        do {    
            let data: [BlockerTableData] = try await SupabaseDB.shared.select(table: "Blocker", filters: ["user_id": user.id.uuidString])
            print("data", data)
            blockedWebsites = data[0].blocked_websites
            blockedApps = data[0].blocked_apps
            blockedAppsList = blockedAppsFromBundleIDs(blockedApps)
            scheduledBlocks = data[0].scheduled_blocks
        } catch {
            print("Error getting blocker table from database: \(error)")
        }
    }

    func blockedAppsFromBundleIDs(_ bundleIDs: [String]) -> [BlockedApp] {
    var result: [BlockedApp] = []
    
    for bundleID in bundleIDs {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID),
           let bundle = Bundle(url: url) {
            
            let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? url.deletingPathExtension().lastPathComponent
            
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            
            let app = BlockedApp(
                name: name,
                bundleIdentifier: bundleID,
                iconPath: url.path
            )
            
            result.append(app)
        } else {
            // fallback if app not found
            let app = BlockedApp(
                name: bundleID, // fallback
                bundleIdentifier: bundleID,
                iconPath: ""
            )
            result.append(app)
        }
    }
    
    return result
}
}
