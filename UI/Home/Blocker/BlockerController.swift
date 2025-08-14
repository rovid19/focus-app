import SwiftUI

class BlockerController: ObservableObject {
    @ObservedObject var blockerManager: BlockerManager

    init(blockerManager: BlockerManager) {
        self.blockerManager = blockerManager
    }

    // Core state
    var selectedProfile: String = "custom"
    @Published var selectedHours: Int = 1
    @Published var remainingTime: Int = 1
    var timer: Timer?

    // Derived
    var totalSeconds: Int {
        max(3600, min(8 * 3600, selectedHours * 3600))
    }

    func toggleBlocker() {
        blockerManager.toggleBlocker()
        if blockerManager.isRunning {
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
        let totalSeconds = selectedHours * 3600
        remainingTime = totalSeconds
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { 
                timer.invalidate()
                return 
            }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                print(self.remainingTime)
            } 
            else {
                timer.invalidate()
            }
        }
    }

    func timerStopped() {
        remainingTime = selectedHours
        self.timer?.invalidate()
    }

}
