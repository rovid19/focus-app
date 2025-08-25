
import Combine
import SwiftUI

class FocusController: ObservableObject {
    var initialTimerMinutes: Int = 1800 {
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
    var allowedTabsDuringBlocking: Int = 3

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

        // change homeController.changePadding when both are true
        Publishers.CombineLatest($isTimerRunning, $isSessionRunning)
            .map { $0 && $1 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bothTrue in
                guard let self = self else { return }
                Task { @MainActor in
                    if bothTrue {
                        self.homeController.changePadding = true
                    } else {
                        self.homeController.changePadding = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func onInitialMinutesChanged() {
        if isSessionRunning { return }
        print("onInitialMinutesChanged", initialTimerMinutes)
        if initialTimerMinutes > 900 {
            print("Timer duration is unlimited")
            isTimerLimited = true
            // setTimerDurationToZero()
        } else {
            print("Timer duration is limited")
            isTimerLimited = false
        }
    }

    func showTime() -> Bool {
        isTimerLimited || isSessionRunning
    }

    private func setTimerDurationToZero() {
        timerMinutes = 0
        initialTimerMinutes = 0
    }

    func decreaseBy5() {
        if timerMinutes == 0 { return }
        if isSessionRunning { return }
        print(initialTimerMinutes)
        timerMinutes = max(900, timerMinutes - 60)
        initialTimerMinutes = max(900, initialTimerMinutes - 60)
        if timerMinutes == 900 {
            timerMinutes = 0
        }
    }

    func decreaseBy15() {
        if timerMinutes == 0 { return }
        if isSessionRunning { return }
        print(initialTimerMinutes)
        timerMinutes = max(900, timerMinutes - 900)
        initialTimerMinutes = max(900, initialTimerMinutes - 900)
        if timerMinutes == 900 {
            timerMinutes = 0
        }
    }

    func increaseBy5() {
        if isSessionRunning { return }
        if timerMinutes == 0 {
            timerMinutes = 960
            initialTimerMinutes = 960
        } else {
            print(initialTimerMinutes)
            timerMinutes += 60
            initialTimerMinutes += 60
        }
    }

    func increaseBy15() {
        if isSessionRunning { return }
        if timerMinutes == 0 {
            timerMinutes = 1800
            initialTimerMinutes = 1800
        } else {
            print(initialTimerMinutes)
            timerMinutes += 900
            initialTimerMinutes += 900
        }
    }

    func toggleHardMode() {
        isHardMode = !isHardMode
        AppStateManager.shared.saveFocusState(FocusSessionState(
            timerMinutes: timerMinutes,
            isTimerRunning: homeController.isTimerRunning,
            isHardMode: isHardMode,
            initialTimerMinutes: initialTimerMinutes
        ))
    }

    func startTimer() async {
        toggleDoNotDisturb()
        TabManager.shared.startBlocking(limit: allowedTabsDuringBlocking)
        homeController.isTimerRunning = true
        var elapsedSeconds = isSessionRunning ? timerMinutes : 0
        isSessionRunning = true

        if isTimerLimited {
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
                    initialTimerMinutes: self.initialTimerMinutes
                ))

                if remainingSeconds <= 0 {
                    t.invalidate()
                    self.homeController.isTimerRunning = false
                    NSSound(named: "Glass")?.play()
                    Task {
                        await self.terminateSession()
                    }
                }
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
                guard let self = self else { t.invalidate(); return }
                elapsedSeconds += 1
                self.timerMinutes = elapsedSeconds
                self.initialTimerMinutes = elapsedSeconds
                print("Timer running: \(elapsedSeconds) seconds")
            }
        }
    }

    func toggleDoNotDisturb() {
        let task = Process()
        task.launchPath = "/usr/bin/shortcuts"
        task.arguments = ["run", "Toggle DND"]
        task.launch()
    }

    func stopTimer() {
        timer?.invalidate()
        if homeController.isTimerRunning {
            homeController.isTimerRunning = false
        }
        timer = nil
    }

    func terminateSession() async {
        toggleDoNotDisturb()
        TabManager.shared.stopBlocking()
        stopTimer()
        homeController.isTimerRunning = false
        isSessionRunning = false
        let secondsToSend = calculateTimeElapsed(seconds: timerMinutes)
        showFinishSessionDialog(secondsToSend: secondsToSend)

        AppStateManager.shared.saveFocusState(FocusSessionState(
            timerMinutes: timerMinutes,
            isTimerRunning: false,
            isHardMode: isHardMode,
            initialTimerMinutes: initialTimerMinutes
        ))

        if isTimerLimited {
            animateTimerReset()
        } else {
            timerMinutes = 0
            initialTimerMinutes = 0
        }
    }

    func calculateTimeElapsed(seconds _: Int) -> Int {
        if initialTimerMinutes > timerMinutes && timerMinutes > 0 {
            return initialTimerMinutes - timerMinutes
        } else {
            return timerMinutes
        }
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

    func showFinishSessionDialog(secondsToSend: Int) {
        homeController.secondsToSend = secondsToSend
        homeController.showFinishSessionDialog = true
    }
}
