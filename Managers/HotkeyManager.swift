import ApplicationServices
import HotKey
import SwiftUI

class HotkeyManager {
    @ObservedObject var homeController: HomeController
    private unowned let appDelegate: AppDelegate

    private var openFocusSession: HotKey?
    private var openBlockerSession: HotKey?
    private var quitHardMode: HotKey?
    private var closeMenuBar: HotKey?

    init(homeController: HomeController, appDelegate: AppDelegate) {
        self.homeController = homeController
        self.appDelegate = appDelegate
        registerHotkey(
            focus: (.a, .option),
            blocker: (.c, .option),
            close: (.escape, .option),
            quitHardMode: (.k, .option)
        )
    }

    func registerHotkey(
        focus: (key: Key, modifiers: NSEvent.ModifierFlags),
        blocker: (key: Key, modifiers: NSEvent.ModifierFlags),
        close: (key: Key, modifiers: NSEvent.ModifierFlags),
        quitHardMode: (key: Key, modifiers: NSEvent.ModifierFlags)
    ) {
        // Focus
        openFocusSession = HotKey(key: focus.key, modifiers: focus.modifiers)
        openFocusSession?.keyDownHandler = { [weak self] in
            guard let self else { return }
            self.appDelegate.activateMenuBar()
            self.homeController.switchView(to: "focus")
        }

        // Blocker
        openBlockerSession = HotKey(key: blocker.key, modifiers: blocker.modifiers)
        openBlockerSession?.keyDownHandler = { [weak self] in
            guard let self else { return }
            if !self.homeController.focusController.isTimerRunning {
                self.appDelegate.activateMenuBar()
                self.homeController.switchView(to: "blocker")
            }
        }

        // Close
        closeMenuBar = HotKey(key: close.key, modifiers: close.modifiers)
        closeMenuBar?.keyDownHandler = { [weak self] in
            self?.appDelegate.deactivateMenuBar()
        }

        // Quit HardMode
        self.quitHardMode = HotKey(key: quitHardMode.key, modifiers: quitHardMode.modifiers)
        self.quitHardMode?.keyDownHandler = { [weak self] in
            self?.killHardmode()
        }
    }

    private func killHardmode() {
        print("killHardmode")
        homeController.focusController.isHardMode = false
        homeController.focusController.isTimerRunning = false
        homeController.focusController.timerMinutes = 0
        homeController.focusController.stopTimer()
        AppStateManager.shared.saveFocusState(
            FocusSessionState(timerMinutes: 0, isTimerRunning: false, isHardMode: false, initialTimerMinutes: 0)
        )
    }
}
