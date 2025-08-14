import SwiftUI

class BlockerController: ObservableObject {
    // Core state
    @Published var selectedHours: Int = 1
    @Published var isRunning: Bool = false
    @Published var hardMode: Bool = false
    @Published var hardLocked: Bool = false
    var selectedProfile: String = "custom"



    // Derived
    var totalSeconds: Int {
        max(3600, min(8 * 3600, selectedHours * 3600))
    }

    // Actions
    func toggleHardMode() {
        guard !hardLocked else { return }
        hardMode.toggle()
    }

    func startBlocker() {
        guard !isRunning else { return }
        isRunning = true
        if hardMode { hardLocked = true }
    }

    func stopOrPauseBlocker() {
        guard isRunning else { return }
        if hardMode && hardLocked { return }
        isRunning = false
    }

 
}
