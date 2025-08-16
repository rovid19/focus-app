//
//  app.swift
//  focus-app
//
//  Created by Roberto Vidovic on 10.08.2025..
//
import SwiftUI
import Cocoa

@main
struct focus_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var supabaseAuth = SupabaseAuth.shared
    @StateObject private var hardModeManager = HardModeManager.shared
    @StateObject private var router: Router
    @StateObject private var homeController: HomeController
    //@StateObject private var blockerManager: BlockerManager

    init() {
        // Init dependencies
        let r = Router()
        //let bm = BlockerManager.shared
        _router = StateObject(wrappedValue: r)
        //_blockerManager = StateObject(wrappedValue: bm)
        _homeController = StateObject(wrappedValue: HomeController(router: r/*, blockerManager: bm*/))

        // Ask for Accessibility permission
        requestAccessibilityPermission()
    }

    var body: some Scene {
        // Always present the menu bar item
        MenuBarExtra("Focus App", systemImage: "brain.head.profile") {
            homeController.homeView
                .environmentObject(supabaseAuth)
                .environmentObject(hardModeManager)
                .environmentObject(router)
                .environmentObject(BlockerManager.shared)
                // Helper that reacts to router changes and opens/closes the window
                .overlay(
                    WindowCoordinator(router: router)
                        .allowsHitTesting(false)
                )
                .onAppear {
                    if BlockerManager.shared.resumeTimer {
                        print("resuming timer in blocker view")
                        homeController.blockerController.timerStarted()
                        BlockerManager.shared.resumeTimer = false
                    }
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
}
