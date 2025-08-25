import SwiftUI

class WebsiteBlockerSettingsController: ObservableObject {
    @Published var newWebsite: String = ""

    func addWebsite(_ website: String) {
        let cleanWebsite = cleanDomain(website)
        if !cleanWebsite.isEmpty && !BlockerManager.shared.blockedWebsites.contains(cleanWebsite) {
            BlockerManager.shared.blockedWebsites.append(cleanWebsite)
            newWebsite = ""
        }
        print("blockedWebsites: \(BlockerManager.shared.blockedWebsites)")
         Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
    }
    
    func removeWebsite(_ website: String) {
        print("removing website: \(BlockerManager.shared.blockedWebsites)")
        BlockerManager.shared.blockedWebsites.removeAll { $0 == website }
        print("blockedWebsites: \(BlockerManager.shared.blockedWebsites)")
         Task {
            await BlockerManager.shared.saveBlockToDatabase()
        }
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

 
}
