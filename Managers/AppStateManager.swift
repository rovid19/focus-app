import SwiftUI

struct BlockerState: Codable {
    var remainingTime: Int
    var isRunning: Bool
    var hardLocked: Bool
}

struct FocusSessionState: Codable {
    var timerMinutes: Int
    var isTimerRunning: Bool
    var isHardMode: Bool
    var initialTimerMinutes: Int
}

final class AppStateManager {
    static let shared = AppStateManager() // singleton

    private let blockerKey = "blockerState"
    private let focusKey = "focusSessionState"
    private let defaults = UserDefaults.standard
    private var blockerState: BlockerState?
    private var focusState: FocusSessionState?

    private init() {} // prevent creating other instances

    // Save
    func saveBlockerState(_ state: BlockerState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: blockerKey)
            print("BlockerState saved: \(state)")
        }
    }

    func saveFocusState(_ state: FocusSessionState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: focusKey)
            print("FocusState saved: \(state)")
        }
    }

    // Load
    func loadBlockerState() {
        guard let data = defaults.data(forKey: blockerKey) else { return }
        blockerState = try? JSONDecoder().decode(BlockerState.self, from: data)
    }

    func loadFocusState() {
        guard let data = defaults.data(forKey: focusKey) else { return }
        focusState = try? JSONDecoder().decode(FocusSessionState.self, from: data)
    }
}


extension AppStateManager {
    func handleBlockerState(homeController: HomeController) {
        loadBlockerState()
        if blockerState?.hardLocked ?? true {
            BlockerManager.shared.hardLocked = true
            BlockerManager.shared.remainingTime = blockerState?.remainingTime ?? 0
            BlockerManager.shared.isRunning = blockerState?.isRunning ?? false
            BlockerManager.shared.resumeTimer = true
            homeController.blockerController.timerStarted()
            BlockerManager.shared.resumeTimer = false
        }
    }

    func handleFocusState(homeController: HomeController) {
        loadFocusState()
        if let state = focusState, state.isHardMode, state.isTimerRunning {
            print("handleFocusState")
            Task { @MainActor in
                await homeController.focusController.sessionQuitDuringHardMode(
                    timerMinutes: self.focusState?.timerMinutes ?? 0,
                    initialTimerMinutes: self.focusState?.initialTimerMinutes ?? 0,
                    isHardMode: self.focusState?.isHardMode ?? false,
                    isTimerRunning: self.focusState?.isTimerRunning ?? false
                )
            }
        }
    }
}
