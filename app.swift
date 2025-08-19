//
//  app.swift
//  focus-app
//

import Cocoa
import SwiftUI

@main
struct focus_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var supabaseAuth = SupabaseAuth.shared

    init() {
        requestAccessibilityPermission()
        //loadState()	
    }

    var body: some Scene {
        // Only Settings remains as a SwiftUI WindowGroup
        WindowGroup("Settings", id: "settings") {
            SettingsView(controller: SettingsController())
                //.environmentObject(appDelegate.router)
                .onDisappear {
                    appDelegate.router.changeView(view: .home)
                }
                .environment(\.font, .custom("Inter-Regular", size: 16))
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 600)
    }

    // MARK: - Helpers

    private func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("Accessibility permission not granted — user has been prompted.")
        }
    }

  
}
