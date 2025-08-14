import SwiftUI

enum ViewType {
    case home
    case settings
}

class Router: ObservableObject {
    @Published var currentView:ViewType = .home

    func changeView(view: ViewType) {
        currentView = view
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
                    print("Opening settings window")
                    focusOrOpenSettings()

                } else {
                    // close any open "settings" windows
                    NSApp.windows
                        .filter { $0.identifier?.rawValue == "settings" }
                        .forEach { $0.close() }
                }
            }
    }

    private func focusOrOpenSettings() {
        if let w = findSettingsWindow() {
            bringToFront(w)
        } else {
            // Not open yet — open, then focus once created
            openWindow(id: "settings")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if let w = findSettingsWindow() {
                    bringToFront(w)
                }
            }
        }
    }

    private func findSettingsWindow() -> NSWindow? {
        // If identifier matching ever fails, fall back to title check
        NSApp.windows.first {
            $0.identifier?.rawValue == "settings"
                || $0.title == "Settings"
        }
    }

    private func bringToFront(_ w: NSWindow) {
        if w.isMiniaturized { w.deminiaturize(nil) } // un-minimize
        NSApp.unhide(nil) // unhide app if hidden
        NSApp.activate(ignoringOtherApps: true) // bring app to front
        w.collectionBehavior.insert(.moveToActiveSpace) // jump to current Space
        w.makeKeyAndOrderFront(nil) // key + front
        w.orderFrontRegardless() // belt-and-suspenders
    }
}
