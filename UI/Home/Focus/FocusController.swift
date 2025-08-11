import SwiftUI

class FocusController: ObservableObject {
    @EnvironmentObject var hardModeManager: HardModeManager
    @Published var timerMinutes: Int = 25
    @Published var isTimerRunning: Bool = false
    private var timer: Timer?

    init() {
        print("FocusController initialized")
    }

    func decreaseBy5() {
        timerMinutes = max(5, timerMinutes - 5)
    }

    func decreaseBy15() {
        timerMinutes = max(5, timerMinutes - 15)
    }

    func increaseBy5() {
        timerMinutes += 5
    }

    func increaseBy15() {
        timerMinutes += 15
    }

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true

        var remainingSeconds = timerMinutes
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            print("Timer running: \(remainingSeconds) seconds")
            remainingSeconds -= 1
            self.timerMinutes = remainingSeconds

            if remainingSeconds <= 0 {
                t.invalidate()
                self.isTimerRunning = false
                NSSound(named: "Glass")?.play()
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

   
}
