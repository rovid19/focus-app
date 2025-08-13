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

    init() {
        let r = Router()
        _router = StateObject(wrappedValue: r)
        _homeController = StateObject(wrappedValue: HomeController(router: r))
    }

    var body: some Scene {
        // Always present the menu bar item
        MenuBarExtra("Focus App", systemImage: "brain.head.profile") {
            homeController.homeView
                .environmentObject(supabaseAuth)
                .environmentObject(hardModeManager)
                .environmentObject(router)
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
                .environmentObject(supabaseAuth)
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

// Opens/closes the Settings window when Router changes
struct WindowCoordinator: View {
    @ObservedObject var router: Router
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        // invisible helper
        Color.clear
            .onChange(of: router.currentView) { _, newValue in
                if newValue == .settings {
                    openWindow(id: "settings")
                } else {
                    // close any open "settings" windows
                    NSApp.windows
                        .filter { $0.identifier?.rawValue == "settings" }
                        .forEach { $0.close() }
                }
            }
    }
}
