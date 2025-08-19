//
//  AppDelegate.swift
//  focus-app
//

import AppKit
import CoreText
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var homeController: HomeController!
     var router: Router = Router()
    var hotkeyManager: HotkeyManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Init shared controllers

        homeController = HomeController(router: router)

        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile",
                                   accessibilityDescription: "Focus App")
            button.action = #selector(togglePopover(_:))
        }

        hotkeyManager = HotkeyManager(homeController: homeController, appDelegate: self)

        // Setup popover
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 460, height: 420)
        popover.contentViewController = makeHostingController()

        // Register fonts if needed
        registerFonts()

       self.loadState()

    }

    // MARK: - Helpers

     func makeHostingController() -> NSHostingController<AnyView> {
        let root = AnyView(
            HomeView(controller: homeController)
                .environmentObject(SupabaseAuth.shared)
                .environmentObject(router)
                .environmentObject(BlockerManager.shared)
                .environmentObject(StatisticsManager.shared)
                .environment(\.font, .custom("Inter-Regular", size: 16))
        )
        return NSHostingController(rootView: root)
    }



    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            // Recreate SwiftUI view tree fresh on every open
            popover.contentViewController = makeHostingController()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    // Fonts
    private func registerFonts() {
        let fontNames = [
            "Inter_18pt-Thin.ttf",
            "Inter_18pt-ExtraLight.ttf",
            "Inter_18pt-Light.ttf",
            "Inter_18pt-Regular.ttf",
            "Inter_18pt-Medium.ttf",
            "Inter_18pt-SemiBold.ttf",
            "Inter_18pt-Bold.ttf",
            "Inter_18pt-ExtraBold.ttf",
        ]

        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(
                forResource: fontName.replacingOccurrences(of: ".ttf", with: ""),
                withExtension: "ttf"
            ) else {
                print("❌ Could not find font file: \(fontName)")
                continue
            }

            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)

            if success {
                print("✅ Successfully registered font: \(fontName)")
            } else {
                print("❌ Failed to register font:")
            }
        }
    }

    // OAuth callback
    func application(_: NSApplication, open urls: [URL]) {
        guard let url = urls.first,
              let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
              .queryItems?.first(where: { $0.name == "code" })?.value
        else { return }

        Task {
            do {
                let session = try await SupabaseAuth.shared
                    .getClient()
                    .auth
                    .exchangeCodeForSession(authCode: code)

                SupabaseAuth.shared.user = session.user
                print("Logged in \(SupabaseAuth.shared.user)")
            } catch {
                NSLog("[focus-app] Exchange failed: \(error)")
            }
        }
    }
     private func loadState() {
        AppStateManager.shared.handleBlockerState(homeController: homeController)
        AppStateManager.shared.handleFocusState(homeController: homeController)
    }
}


// MARK: - Popup control
extension AppDelegate {
    func activateMenuBar() {
        if let button = statusItem.button {
            popover.contentViewController = makeHostingController()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func deactivateMenuBar() {
        popover.performClose(nil)
    }
}
