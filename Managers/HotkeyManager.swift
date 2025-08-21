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

    private var lastRegistered: (
        focus: (key: Key, modifiers: NSEvent.ModifierFlags),
        blocker: (key: Key, modifiers: NSEvent.ModifierFlags),
        close: (key: Key, modifiers: NSEvent.ModifierFlags),
        quitHardMode: (key: Key, modifiers: NSEvent.ModifierFlags)
    )?

    init(homeController: HomeController, appDelegate: AppDelegate) {
        self.homeController = homeController
        self.appDelegate = appDelegate
        registerHotkey(
            focus: (.a, .option),
            blocker: (.c, .option),
            close: (.escape, .option),
            quit: (.k, .option)
        )
    }

    func registerHotkey(
        focus: (key: Key, modifiers: NSEvent.ModifierFlags),
        blocker: (key: Key, modifiers: NSEvent.ModifierFlags),
        close: (key: Key, modifiers: NSEvent.ModifierFlags),
        quit: (key: Key, modifiers: NSEvent.ModifierFlags) // 👈 renamed
    ) {
        lastRegistered = (focus, blocker, close, quit)

        print("registerHotkey", focus)

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
        quitHardMode = HotKey(key: quit.key, modifiers: quit.modifiers) // 👈 now uses parameter `quit`
        quitHardMode?.keyDownHandler = { [weak self] in
            self?.killHardmode()
        }
    }

    /// Disable all registered hotkeys (for recording mode)
    func pauseHotkeys() {
        openFocusSession = nil
        openBlockerSession = nil
        closeMenuBar = nil
        quitHardMode = nil
    }

    /// Re-enable the last registered hotkeys
    func resumeHotkeys() {
        if let last = lastRegistered {
            print("resumeHotkeys", last)
            registerHotkey(
                focus: last.focus,
                blocker: last.blocker,
                close: last.close,
                quit: last.quitHardMode
            )
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
