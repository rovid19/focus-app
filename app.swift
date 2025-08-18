//
//  app.swift
//  focus-app
//
//  Created by Roberto Vidovic on 10.08.2025..
//

import Cocoa
import SwiftUI

@main
struct focus_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var supabaseAuth = SupabaseAuth.shared
    @StateObject private var router: Router
    @StateObject private var homeController: HomeController
 

    init() {
        let r = Router()
        let hc = HomeController(router: r)

        _router = StateObject(wrappedValue: r)
        _homeController = StateObject(wrappedValue: hc)

        loadState(hc: hc)
        requestAccessibilityPermission()
    }

    var body: some Scene {
        MenuBarExtra("Focus App", systemImage: "brain.head.profile") {
            homeController.homeView
                .environmentObject(supabaseAuth)
                .environmentObject(router)
                .environmentObject(BlockerManager.shared)
                .environmentObject(StatisticsManager.shared)
                .overlay(WindowCoordinator(router: router).allowsHitTesting(false))
                .environment(\.font, .custom("Inter-Regular", size: 16))
                .onAppear {
                    makeWindowOpaque(window: NSApp.windows.first(where: { $0.level == .popUpMenu })!)
                }
        }
        .menuBarExtraStyle(.window)

        WindowGroup("Settings", id: "settings") {
            SettingsView(controller: SettingsController())
                .environmentObject(router)
                .onDisappear {
                    router.changeView(view: .home)
                }
                .environment(\.font, .custom("Inter-Regular", size: 16))
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 600)
    }

    private func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("Accessibility permission not granted — user has been prompted.")
        }
    }

    private func loadState(hc: HomeController) {
        let blockerState = AppStateManager.shared.loadBlockerState()
        let focusState = AppStateManager.shared.loadFocusState()

        if blockerState?.hardLocked ?? true {
            BlockerManager.shared.hardLocked = true
            BlockerManager.shared.remainingTime = blockerState?.remainingTime ?? 0
            BlockerManager.shared.isRunning = blockerState?.isRunning ?? false
            BlockerManager.shared.resumeTimer = true
            homeController.blockerController.timerStarted()
            BlockerManager.shared.resumeTimer = false
        }
        if let state = focusState, state.isHardMode, state.isTimerRunning {
            Task { @MainActor in
                await hc.focusController.sessionQuitDuringHardMode(
                    timerMinutes: AppStateManager.shared.loadFocusState()?.timerMinutes ?? 0,
                    initialTimerMinutes: AppStateManager.shared.loadFocusState()?.initialTimerMinutes ?? 0,
                    isHardMode: AppStateManager.shared.loadFocusState()?.isHardMode ?? false,
                    isTimerRunning: AppStateManager.shared.loadFocusState()?.isTimerRunning ?? false
                )
            }
        }
    }

    private func makeWindowOpaque(window _: NSWindow) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let menuBarWindow = NSApp.windows.first(where: { $0.level == .popUpMenu }) {
                menuBarWindow.isOpaque = false
                menuBarWindow.backgroundColor = .clear
                menuBarWindow.hasShadow = false

                if let contentView = menuBarWindow.contentView {
                    contentView.wantsLayer = true
                    if let layer = contentView.layer {
                        layer.cornerRadius = 12
                        layer.masksToBounds = true
                        layer.borderWidth = 1
                        layer.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
                    }
                }
            }
        }
    }
}
