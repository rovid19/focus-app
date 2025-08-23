import SwiftUI

@MainActor
class StatsSettingsController: ObservableObject {
    @Published var settings: StatsSettings = StatsSettings()
    weak var homeController: HomeController?
    var socialMediaShareController = SocialMediaShareController()
    
    init(homeController: HomeController? = nil) {
        self.homeController = homeController
    }
    
    func loadSettings() {
        // Load stats-specific settings
    }
    
    func saveSettings() {
        // Save stats-specific settings
    }
}

struct StatsSettings {
    var trackingEnabled: Bool = true
    var exportFormat: ExportFormat = .csv
    var retentionDays: Int = 365
    var showWeeklyReports: Bool = true
}

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case json = "JSON"
    case pdf = "PDF"
}
