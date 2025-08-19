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
        registerHotkey()
    }

    private func registerHotkey() {
        // ⌥A → open Focus view
        openFocusSession = HotKey(key: .a, modifiers: [.option])
        openFocusSession?.keyDownHandler = { [weak self] in
            guard let self else { return }
            self.appDelegate.activateMenuBar()
            self.homeController.switchView(to: "focus")
        }

        // ⌥C → open Blocker view
        openBlockerSession = HotKey(key: .c, modifiers: [.option])
        openBlockerSession?.keyDownHandler = { [weak self] in
            guard let self else { return }
            if !self.homeController.focusController.isTimerRunning {
                self.appDelegate.activateMenuBar()
                self.homeController.switchView(to: "blocker")
            }
        }

        // ⌥Esc → close popup
        closeMenuBar = HotKey(key: .escape, modifiers: [.option])
        closeMenuBar?.keyDownHandler = { [weak self] in
            self?.appDelegate.deactivateMenuBar()
        }

        // ⌥K → quit HardMode
        quitHardMode = HotKey(key: .k, modifiers: [.option])
        quitHardMode?.keyDownHandler = { [weak self] in
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
