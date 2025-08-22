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
        requestAppleScriptPermission()
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

    private func requestAppleScriptPermission() {
        let script = """
        tell application "System Events"
            return "ok"
        end tell
        """
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if error != nil {
                print("Automation permission not granted — macOS should prompt when first needed.")
            } else {
                print("Automation permission already granted ✅")
            }
        }
    }
}
