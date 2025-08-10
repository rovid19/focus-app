import SwiftUI

class FocusController: ObservableObject {
    @Published var timerMinutes: Int = 25
    @Published var isTimerRunning: Bool = false
    
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
        
        let totalSeconds = timerMinutes
        var remainingSeconds = totalSeconds
        
        NSLog("[gptapp] Starting timer for \(timerMinutes) seconds")
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            print("Timer running: \(remainingSeconds) seconds")
            remainingSeconds -= 1
            self.timerMinutes = remainingSeconds
            
            if remainingSeconds <= 0 {
                timer.invalidate()
                self.isTimerRunning = false
                NSLog("[gptapp] Timer finished")
                NSSound(named: "Glass")?.play()
            }
        }
    }
}