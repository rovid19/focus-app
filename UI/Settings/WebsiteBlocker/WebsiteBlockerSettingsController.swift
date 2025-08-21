import SwiftUI

class WebsiteBlockerSettingsController: ObservableObject {
    @Published var blockedWebsites: [String] = ["youtube.com", "twitter.com", "reddit.com", "facebook.com", "instagram.com"]
    @Published var newWebsite: String = ""
    
    func addWebsite(_ website: String) {
        let cleanWebsite = cleanDomain(website)
        if !cleanWebsite.isEmpty && !blockedWebsites.contains(cleanWebsite) {
            blockedWebsites.append(cleanWebsite)
            newWebsite = ""
        }
        print("blockedWebsites: \(blockedWebsites)")
        saveBlockedWebsitesToWebsiteBlocker()
    }
    
    func removeWebsite(_ website: String) {
        blockedWebsites.removeAll { $0 == website }
        saveBlockedWebsitesToWebsiteBlocker()
    }
    
    private func cleanDomain(_ input: String) -> String {
        var domain = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Remove protocol if present
        if domain.hasPrefix("http://") || domain.hasPrefix("https://") {
            if let url = URL(string: domain) {
                domain = url.host ?? domain
            }
        }
        
        // Remove www. prefix
        if domain.hasPrefix("www.") {
            domain = String(domain.dropFirst(4))
        }
        
        return domain
    }

    private func saveBlockedWebsitesToWebsiteBlocker() {
        BlockerManager.shared.blockedWebsites = blockedWebsites
        Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
    }
}
