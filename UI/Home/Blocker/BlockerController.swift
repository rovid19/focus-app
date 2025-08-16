import SwiftUI

class BlockerController: ObservableObject {
    // Core state
    var selectedProfile: String = "custom"
    @Published var selectedHours: Int = 1

    var timer: Timer?

    // Derived
    var totalSeconds: Int {
        max(3600, min(8 * 3600, selectedHours * 3600))
    }

    func toggleBlocker() {
        print("toggleBlocker")
        BlockerManager.shared.toggleBlocker()
        if BlockerManager.shared.isRunning {
            timerStarted()
        } else {
            timerStopped()
        }
    }

    func formattedTimeLeft(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    func timerStarted() {
        var totalSeconds = 0

        // Snapshot the value outside SwiftUI's render cycle
        let resume = BlockerManager.shared.resumeTimer
        let remaining = BlockerManager.shared.remainingTime

        if !resume {
            totalSeconds = selectedHours * 3600
            BlockerManager.shared.remainingTime = totalSeconds
        } else {
            totalSeconds = remaining
        }

        print("totalSeconds: \(totalSeconds)")

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if BlockerManager.shared.remainingTime > 0 {
                BlockerManager.shared.remainingTime -= 1
                print(BlockerManager.shared.remainingTime)
                BlockerManager.shared.saveState()
            } else {
                timer.invalidate()
            }
        }
    }

    func timerStopped() {
        BlockerManager.shared.remainingTime = selectedHours * 3600
        timer?.invalidate()
        BlockerManager.shared.saveState()
    }


}
