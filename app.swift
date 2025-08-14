//
//  app.swift
//  focus-app
//
//  Created by Roberto Vidovic on 10.08.2025..
//
import SwiftUI

@main
struct focus_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var supabaseAuth = SupabaseAuth.shared
    @StateObject private var hardModeManager = HardModeManager.shared
    @StateObject private var router: Router
    @StateObject private var homeController: HomeController
    @StateObject private var blockerManager: BlockerManager

    init() {
        let r = Router()
        let bm = BlockerManager.shared
        _router = StateObject(wrappedValue: r)
        _blockerManager = StateObject(wrappedValue: bm)
        _homeController = StateObject(wrappedValue: HomeController(router: r, blockerManager: bm))
    }

    var body: some Scene {
        // Always present the menu bar item
        MenuBarExtra("Focus App", systemImage: "brain.head.profile") {
            homeController.homeView
                .environmentObject(supabaseAuth)
                .environmentObject(hardModeManager)
                .environmentObject(router)
                .environmentObject(blockerManager)
                // Helper that reacts to router changes and opens/closes the window
                .overlay(
                    WindowCoordinator(router: router)
                        .allowsHitTesting(false)
                )
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
}

