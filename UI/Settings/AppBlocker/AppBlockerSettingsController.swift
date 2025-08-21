import SwiftUI
import AppKit

class AppBlockerSettingsController: ObservableObject {
    @Published var blockedApps: [BlockedApp] = [
        BlockedApp(name: "Safari", bundleIdentifier: "com.apple.Safari", iconPath: "/System/Applications/Safari.app"),
        BlockedApp(name: "Chrome", bundleIdentifier: "com.google.Chrome", iconPath: "/Applications/Google Chrome.app"),
        BlockedApp(name: "Discord", bundleIdentifier: "com.hnc.Discord", iconPath: "/Applications/Discord.app")
    ]
    
    func addApp(_ app: BlockedApp) {
        if !blockedApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            blockedApps.append(app)
            saveSettings()
        }   
        saveBlockedAppsToDatabase()
    }
    
    func removeApp(_ app: BlockedApp) {
        blockedApps.removeAll { $0.bundleIdentifier == app.bundleIdentifier }
        saveSettings()
        saveBlockedAppsToDatabase()
    }
    
    func openApplicationsPicker() {
        let panel = NSOpenPanel()
        panel.title = "Select Application to Block"
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                let app = createBlockedApp(from: url)
                addApp(app)
            }
        }
    }
    
    private func createBlockedApp(from url: URL) -> BlockedApp {
        let bundle = Bundle(url: url)
        let appName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                   ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                   ?? url.deletingPathExtension().lastPathComponent
        
        let bundleIdentifier = bundle?.bundleIdentifier ?? url.lastPathComponent
        
        return BlockedApp(
            name: appName,
            bundleIdentifier: bundleIdentifier,
            iconPath: url.path
        )
    }
    
    private func loadSettings() {
        // Load from UserDefaults or other persistence
    }
    
    private func saveSettings() {
        // Save to UserDefaults or other persistence
    }

    private func saveBlockedAppsToDatabase() {
        BlockerManager.shared.blockedApps = blockedApps.map { $0.bundleIdentifier }
        Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
    }
}

struct BlockedApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let iconPath: String
    
    var icon: NSImage? {
        return NSWorkspace.shared.icon(forFile: iconPath)
    }
}
