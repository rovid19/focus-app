import SwiftUI

@MainActor
class SocialMediaShareController: ObservableObject {
    @Published var showingSummaryPopup = false
    @Published var todaySummary: SocialMediaSummary?

    init() {
        todaySummary = StatisticsManager.shared.generateSocialMediaSummary()
        todaySummary?.focusTime
    }

    func createTodaySummary() {
        showingSummaryPopup = true
    }
}
