import SwiftUI

class BlockerController: ObservableObject {
    // Core state
    var selectedProfile: String = "custom"
    @Published var selectedHours: Int = 1

    var timer: Timer?
    var scheduleTimer: Timer?

    init() {
        startScheduledBlock()
        if !BlockerManager.shared.isRunning {
            startScheduleListener()
        }
    }

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
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
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
                AppStateManager.shared.saveBlockerState(BlockerState(remainingTime: BlockerManager.shared.remainingTime, isRunning: BlockerManager.shared.isRunning, hardLocked: BlockerManager.shared.hardLocked))
            } else {
                timer.invalidate()
            }
        }
    }

    func timerStopped() {
        BlockerManager.shared.remainingTime = selectedHours * 3600
        timer?.invalidate()
        AppStateManager.shared.saveBlockerState(BlockerState(remainingTime: BlockerManager.shared.remainingTime, isRunning: BlockerManager.shared.isRunning, hardLocked: BlockerManager.shared.hardLocked))
    }

    func startScheduledBlock() {
        guard let scheduledBlocks = BlockerManager.shared.scheduledBlocks else {return}
        let currentTime = Date()

        let tolerance: TimeInterval = 120 // 2 minutes in seconds

        for block in scheduledBlocks {
            let startWindow = block.starts.addingTimeInterval(-tolerance)
            let endWindow = block.starts.addingTimeInterval(tolerance)

            // If we are within 2 minutes before/after start, and before block end
            if currentTime >= startWindow, currentTime <= endWindow, currentTime <= block.ends {
                BlockerManager.shared.remainingTime = block.blockDuration
                toggleBlocker()
            }
        }
    }

    func startScheduleListener() {
        // Invalidate existing one if already running
        scheduleTimer?.invalidate()

        scheduleTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.startScheduledBlock()
        }
    }
}
