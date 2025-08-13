import SwiftUI

class FocusController: ObservableObject {
    @EnvironmentObject var hardModeManager: HardModeManager
    private(set) var initialTimerMinutes: Int = 25
    @Published var timerMinutes: Int = 25
    @Published var isTimerRunning: Bool = false
    private var timer: Timer?
    private var homeController: HomeController

    init(homeController: HomeController) {
        self.homeController = homeController
        print("FocusController initialized")
    }

    func decreaseBy5() {
        timerMinutes = max(5, timerMinutes - 5)
        initialTimerMinutes = max(5, initialTimerMinutes - 5)
    }

    func decreaseBy15() {
        timerMinutes = max(5, timerMinutes - 15)    
        initialTimerMinutes = max(5, initialTimerMinutes - 15)
    }   

    func increaseBy5() {
        timerMinutes += 5
        initialTimerMinutes += 5
    }

    func increaseBy15() {
        timerMinutes += 15
        initialTimerMinutes += 15
    }

    func startTimer() async {
        guard !isTimerRunning else { return }
        homeController.isTimerRunning = true
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
                self.homeController.isTimerRunning = false
                NSSound(named: "Glass")?.play()
                Task {
                    await StatisticsManager.shared.addStat(title: "Focus", time_elapsed: self.initialTimerMinutes * 60)
                }
              
            }
        }
    }
    
    

    func stopTimer() {
        isTimerRunning = false
        homeController.isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

   
}
