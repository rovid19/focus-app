//
//  AppDelegate.swift
//  focus-app
//

import AppKit
import CoreText
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var homeController: HomeController!
    var settingsController: SettingsController!
    var router: Router = .init()
    var hotkeyManager: HotkeyManager!
    var statsManager: StatisticsManager!
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Init shared controllers
        homeController = HomeController(router: router, appDelegate: self)
        hotkeyManager = HotkeyManager(homeController: homeController, appDelegate: self)
        settingsController = SettingsController(homeController: homeController, hotkeyManager: hotkeyManager)
        statsManager = StatisticsManager.shared
        Task {
            await homeController.checkAuth()
            await settingsController.generalController.updateUserDefaults()
        }

        setupPopover()

        // Register fonts
        registerFonts()
        loadState()
    }

    func applicationShouldTerminate(_: NSApplication) -> NSApplication.TerminateReply {
        if homeController.focusController.isTimerRunning {
            Task.detached(priority: .high) {
                await self.homeController.focusController.terminateSession()
                NSApp.reply(toApplicationShouldTerminate: true)
            }
            return .terminateLater
        } else {
            return .terminateNow
        }
    }

    func popoverDidShow(_: Notification) {
        guard let window = popover?.contentViewController?.view.window,
              let frameView = window.contentView?.superview else { return }

        window.isOpaque = false
        window.backgroundColor = .clear

        frameView.wantsLayer = true
        frameView.layer?.cornerRadius = 8
        frameView.layer?.masksToBounds = true

        // Kill the bright border by painting over it
        frameView.layer?.borderWidth = 1
        frameView.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
    }

    // MARK: - Helpers

    func setupPopover() {
        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile",
                                   accessibilityDescription: "Focus App")
            button.action = #selector(togglePopover(_:))
        }

        // Setup popover
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 460, height: 420)
        popover.contentViewController = makeHostingController()
        popover.delegate = self
    }

    func makeHostingController() -> NSHostingController<AnyView> {
        let root = AnyView(
            HomeView(controller: homeController)
                .environmentObject(SupabaseAuth.shared)
                .environmentObject(router)
                .environmentObject(BlockerManager.shared)
                .environmentObject(statsManager)
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
            if let window = popover.contentViewController?.view.window {
                window.backgroundColor = .clear // transparent background
                window.isOpaque = false
                window.contentView?.superview?.wantsLayer = true
                window.contentView?.superview?.layer?.cornerRadius = 16
                window.contentView?.superview?.layer?.masksToBounds = true
            }

            Task {
                await StatisticsManager.shared.getStatsFromDatabaseIfNeeded()
                await BlockerManager.shared.getBlockerTable()
            }
        }
    }

    func openSettingsWindow() {
        // Build hosting view
        let hosting = NSHostingView(
            rootView: SettingsView(controller: settingsController)
                .environmentObject(SupabaseAuth.shared)
                .environmentObject(router)
                .environmentObject(statsManager)
                .environment(\.font, .custom("Inter-Regular", size: 16))
                .fixedSize() // 🔹 makes SwiftUI report natural size
        )

        // Ask SwiftUI view for its intrinsic size
        let size = hosting.intrinsicContentSize

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.title = "Settings"
        window.contentView = hosting
        window.isOpaque = false
        window.backgroundColor = .clear

        window.center()
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)

        // keep reference until closed
        window.isReleasedWhenClosed = false
        window.delegate = self
        settingsWindow = window

        // cleanup when closed
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.settingsWindow = nil
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
        guard let url = urls.first else {
            return
        }

        guard let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return
        }

        Task {
            do {
                let session = try await SupabaseAuth.shared
                    .getClient()
                    .auth
                    .exchangeCodeForSession(authCode: code)

                SupabaseAuth.shared.user = session.user

            } catch {
                NSLog("[AUTH FLOW] Error exchanging code for session: \(error)")
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
            Task {
                await StatisticsManager.shared.getStatsFromDatabaseIfNeeded()
            }
        }
    }

    func deactivateMenuBar() {
        popover.performClose(nil)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window == settingsWindow {
            Task { @MainActor in
                await StatisticsManager.shared.getStatsFromDatabaseIfNeeded()
                await BlockerManager.shared.getBlockerTable()
            }
        }
    }
}

