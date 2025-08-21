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
    }

    var body: some Scene {
        // keep SwiftUI happy, but don’t auto-create your Settings window
        Settings {}
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
