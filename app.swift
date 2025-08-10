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
    @StateObject private var appCoordinator: AppCoordinator
    @StateObject private var supabaseAuth = SupabaseAuth.shared

    init() {
        let homeController = HomeController()
        _appCoordinator = StateObject(
            wrappedValue: AppCoordinator(homeController: homeController)
        )
    }

    var body: some Scene {
        MenuBarExtra("Focus App", systemImage: "brain.head.profile") {
            RootView()
                .environmentObject(appCoordinator)
                .environmentObject(supabaseAuth)
        }
        .menuBarExtraStyle(.window)
    }
}
