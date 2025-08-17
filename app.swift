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
    // @StateObject private var blockerManager: BlockerManager

    init() {
        let r = Router()
        let hc = HomeController(router: r)

        _router = StateObject(wrappedValue: r)
        _homeController = StateObject(wrappedValue: hc)

        // ✅ Call loadState here instead of AppDelegate
        loadState(hc: hc)

        requestAccessibilityPermission()
    }

    var body: some Scene {
        // Always present the menu bar item
        MenuBarExtra("Focus App", systemImage: "brain.head.profile") {
            homeController.homeView
                .environmentObject(supabaseAuth)
                .environmentObject(router)
                .environmentObject(BlockerManager.shared)
                // Helper that reacts to router changes and opens/closes the window
                .overlay(
                    WindowCoordinator(router: router)
                        .allowsHitTesting(false)
                )
                .onAppear {
                    if BlockerManager.shared.resumeTimer {}
                }
        }
        .menuBarExtraStyle(.window)

        // Settings window exists, but we only open it when needed
        WindowGroup("Settings", id: "settings") {
            SettingsView(controller: SettingsController())
                .environmentObject(router)
                .onDisappear {
                    router.changeView(view: .home)
                    print("Settings window closed")
                    print(router.currentView)
                }
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

        print("focusState", focusState)
        print("blockerState", blockerState)

        if blockerState?.hardLocked ?? true {
            print("blockerState locked")
            BlockerManager.shared.hardLocked = true
            BlockerManager.shared.remainingTime = blockerState?.remainingTime ?? 0
            BlockerManager.shared.isRunning = blockerState?.isRunning ?? false  
            BlockerManager.shared.resumeTimer = true
            print("resuming timer in blocker view")
            homeController.blockerController.timerStarted()
            BlockerManager.shared.resumeTimer = false
        }
        if let state = focusState, state.isHardMode, state.isTimerRunning {
            print("ran")
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
}
