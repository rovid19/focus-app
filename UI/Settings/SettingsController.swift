import SwiftUI

@MainActor
class SettingsController: ObservableObject {
    @Published var selectedSection: SettingsSection = .blocker
 
    // top level controllers
    weak var homeController: HomeController?
    weak var hotkeyManager: HotkeyManager?
    // Child controllers
    lazy var appBlockerController = AppBlockerSettingsController()
    lazy var websiteBlockerController = WebsiteBlockerSettingsController()
    lazy var generalController = GeneralSettingsController(hotkeyManager: hotkeyManager, homeController: homeController)
    lazy var statsController = StatsSettingsController(homeController: self.homeController)
 
    init(homeController: HomeController? = nil, hotkeyManager: HotkeyManager? = nil) {
        self.homeController = homeController
        self.hotkeyManager = hotkeyManager
    }
    
    func loadSettings() {
        // Initialize any necessary settings data
    }
    
    func switchSection(to section: SettingsSection) {
        selectedSection = section
    }
}

enum SettingsSection: String, CaseIterable {
    case blocker = "Website Blocker"
    case apps = "App Blocker"
    case stats = "Detailed Statistics"
    case general = "General"
    
    var icon: String {
        switch self {
        case .blocker: return "globe"
        case .apps: return "app.badge"
        case .stats: return "chart.bar"
        case .general: return "gear"
        }
    }
    
        var description: String {
        switch self {
        case .blocker: return "Manage blocked domains"
        case .apps: return "Limit desktop apps"
        case .stats: return "Focus insights"
        case .general: return "App preferences"
        }
    }
    
    
}

