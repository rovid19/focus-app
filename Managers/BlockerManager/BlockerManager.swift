import SwiftUI

class BlockerManager: ObservableObject {
    static let shared = BlockerManager()
    var blockedApps: [String] = []
    var blockedWebsites: [String] = []
    @Published var isRunning: Bool = false
    @Published var hardLocked: Bool = false

    private init() {}

    func toggleBlocker() {
        if isRunning {
            isRunning = false
        } else {
            isRunning = true
        }
    }

    func toggleHardLocked() {
        if hardLocked {
            hardLocked = false
        } else {
            hardLocked = true
        }
    }
}
