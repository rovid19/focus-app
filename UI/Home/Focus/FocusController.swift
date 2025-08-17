
import Combine
import SwiftUI

class FocusController: ObservableObject {
    private(set) var initialTimerMinutes: Int = 1800 {
        didSet {
            onInitialMinutesChanged()
        }
    }
    @Published var isTimerRunning: Bool = false
    @Published var timerMinutes: Int = 1800
    @Published var isSessionRunning: Bool = false
    @Published var isHardMode: Bool = false
    private var timer: Timer?
    @Published var isTimerLimited: Bool = true
    @ObservedObject var homeController: HomeController
     private var cancellables = Set<AnyCancellable>()
    
    // Computed property that combines your conditional logic
    var shouldHideControls: Bool {
        return isSessionRunning // Change this single line to control all conditional rendering
    }
    
    // Computed property for timer running state - centralized control point
    var isTimerActive: Bool {
        return isTimerRunning // Change this single line to control all timer-running conditional rendering
    }


    init(homeController: HomeController) {
        self.homeController = homeController

        // Keep in sync with homeController.isTimerRunning
        homeController.$isTimerRunning
            .receive(on: RunLoop.main)
            .assign(to: \.isTimerRunning, on: self)
            .store(in: &cancellables)
    }

    private func onInitialMinutesChanged() {
        if initialTimerMinutes > 0 {
            print("Timer duration is limited")
            isTimerLimited = true
        } else {
            print("Timer duration is unlimited")
            isTimerLimited = false
        }
    }

    func decreaseBy5() {
        if isSessionRunning { return }
        print(initialTimerMinutes)
        timerMinutes = max(0, timerMinutes - 60)
        initialTimerMinutes = max(0, initialTimerMinutes - 60)
    }

    func decreaseBy15() {
        if isSessionRunning { return }
        print(initialTimerMinutes)
        timerMinutes = max(0, timerMinutes - 900)
        initialTimerMinutes = max(0, initialTimerMinutes - 900)
    }

    func increaseBy5() {
        if isSessionRunning { return }
        print(initialTimerMinutes)
        timerMinutes += 60
        initialTimerMinutes += 60
    }

    func increaseBy15() {
        if isSessionRunning { return }
        print(initialTimerMinutes)
        timerMinutes += 900
        initialTimerMinutes += 900
    }

    func toggleHardMode() {
        print("toggleHardMode on focus controller")
        isHardMode = !isHardMode
        AppStateManager.shared.saveFocusState(FocusSessionState(
            timerMinutes: timerMinutes, 
            isTimerRunning: homeController.isTimerRunning, 
            isHardMode: isHardMode, 
            initialTimerMinutes: initialTimerMinutes))
    }

    func startTimer() async {
        print("startTimer on focus controller")
        //guard !homeController.isTimerRunning else { return }
        homeController.isTimerRunning = true
        isSessionRunning = true
        print(isTimerLimited)
        if isTimerLimited {
            print("timer is limited")
            // Countdown mode
            var remainingSeconds = timerMinutes
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
                guard let self = self else { t.invalidate(); return }
                print("Timer running: \(remainingSeconds) seconds")
                remainingSeconds -= 1
                self.timerMinutes = remainingSeconds
                AppStateManager.shared.saveFocusState(FocusSessionState(
                    timerMinutes: remainingSeconds, 
                    isTimerRunning: true, 
                    isHardMode: self.isHardMode,
                    initialTimerMinutes: self.initialTimerMinutes))

                if remainingSeconds <= 0 {
                    t.invalidate()
                    self.homeController.isTimerRunning = false
                    NSSound(named: "Glass")?.play()
                    self.terminateSession()
                }
            }
        } else {
            // Unlimited mode (count up)
            var elapsedSeconds = timerMinutes
            timerMinutes = timerMinutes // start from zero

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
                guard let self = self else { t.invalidate(); return }
                elapsedSeconds += 1
                self.timerMinutes = elapsedSeconds
                print("Timer running: \(elapsedSeconds) seconds")
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        if homeController.isTimerRunning {
            homeController.isTimerRunning = false
        }
        timer = nil
        print("timer running", homeController.isTimerRunning)
        print("session running", isSessionRunning)
    }

    func terminateSession() {
        stopTimer()
        homeController.isTimerRunning = false
        isSessionRunning = false

        let minutesToSend = initialTimerMinutes == 0
            ? timerMinutes
            : (timerMinutes == 0 ? initialTimerMinutes : timerMinutes)

        print("initialTimerMinutes", initialTimerMinutes)
        print("timerMinutes", timerMinutes)
        print("minutesToSend", minutesToSend)

        Task {
            await StatisticsManager.shared.addStat(
                title: "Focus",
                time_elapsed: minutesToSend
            )
        }

        // Animate the reset by gradually changing the timer value
        if isTimerLimited {
            animateTimerReset()
        } else {
            timerMinutes = 0
            initialTimerMinutes = 0
        }

        AppStateManager.shared.saveFocusState(FocusSessionState(
            timerMinutes: self.timerMinutes, 
            isTimerRunning: false, 
            isHardMode: self.isHardMode, 
            initialTimerMinutes: self.initialTimerMinutes))

    }

    private func animateTimerReset() {
        let startValue = timerMinutes
        let targetValue = 1800
        let steps = 20
        let stepDuration = 0.8 / Double(steps)

        for i in 0 ... steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                let progress = Double(i) / Double(steps)
                let currentValue = Int(Double(startValue) + (Double(targetValue - startValue) * progress))
                self.timerMinutes = currentValue

                if i == steps {
                    self.initialTimerMinutes = 1800
                }
            }
        }
    }

    func sessionQuitDuringHardMode(timerMinutes: Int, initialTimerMinutes: Int, isHardMode: Bool, isTimerRunning: Bool) async {
        print("sessionQuitDuringHardMode", timerMinutes, initialTimerMinutes, isHardMode, isTimerRunning, timerMinutes)
        homeController.isTimerRunning = isTimerRunning
        self.initialTimerMinutes = initialTimerMinutes
        self.isHardMode = isHardMode
        self.timerMinutes = timerMinutes
        await startTimer()
        
    }
}
