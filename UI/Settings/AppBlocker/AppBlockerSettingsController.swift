import SwiftUI
import AppKit

// in this file i used two lists - blockedAppsList and blockedApps
// blockedAppsList is used to display the list of blocked apps in the UI
// blockedApps is used to save the list of blocked apps to the database
// i did this because i need to display the icons of the blocked apps in the UI
// and i need to save the list of blocked apps to the database as a string array
// so i created two lists, one with the blocked apps and one with the blocked apps and their icons

class AppBlockerSettingsController: ObservableObject {
    
    func addApp(app: BlockedApp) {
        if !BlockerManager.shared.blockedAppsList.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            // koristim blockedAppsList i blockedApps - zato jer trebam slikice na listi blokanih appsa
            // ali vec imam implemntaciju za string array na blocker manageru za blokiranje appsa, pa sad radim
            // špagetu od koga i dodajem zapravo dvije iste liste, jedna ima samo bundle identifiere, a druga
            // ima slike i nazive appsa za ljepsi prikaz
            BlockerManager.shared.blockedAppsList.append(app)
            BlockerManager.shared.blockedApps = BlockerManager.shared.blockedAppsList.map { $0.bundleIdentifier }
        }   
        Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
    }
    
    func removeApp(app: BlockedApp) {
        BlockerManager.shared.blockedAppsList.removeAll { $0.bundleIdentifier == app.bundleIdentifier }
        BlockerManager.shared.blockedApps = BlockerManager.shared.blockedAppsList.map { $0.bundleIdentifier }
        Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
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
                addApp(app: app)
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


   /* private func saveBlockedAppsToDatabase() {
        BlockerManager.shared.blockedApps = blockedApps.map { $0.bundleIdentifier }
        Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
    }*/
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
