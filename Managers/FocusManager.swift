import SwiftUI

class FocusManager: ObservableObject {
    static let shared = FocusManager()
    @Published var isTimerRunning: Bool = false
    @Published var timerMinutes: Int = 45
    @Published var isHardMode: Bool = false

     init() {}

    func toggleHardMode() {
        isHardMode = !isHardMode
        AppStateManager.shared.saveFocusState(FocusSessionState(timerMinutes: timerMinutes, isTimerRunning: isTimerRunning, isHardMode: isHardMode))
    }
}