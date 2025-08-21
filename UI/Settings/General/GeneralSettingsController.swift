import SwiftUI
import HotKey

// MARK: - Controller
class GeneralSettingsController: ObservableObject {
    @Published var settings: GeneralSettings = .init()
    weak var hotkeyManager: HotkeyManager?

    // Hotkey recording states
    @Published var isRecordingFocusHotkey = false
    @Published var isRecordingBlockerHotkey = false
    @Published var isRecordingCloseHotkey = false

    // Default key map
    var hotkeys: [HotkeyAction: (key: Key, modifiers: NSEvent.ModifierFlags)] = [
        .focus: (.a, .option),
        .blocker: (.c, .option),
        .close: (.escape, .option),
        .quitHardMode: (.k, .option),
    ]

    init(hotkeyManager: HotkeyManager? = nil) {
        self.hotkeyManager = hotkeyManager
    }

    // Start "recording" a hotkey → UI shows "Press keys..."
    func startRecordingHotkey(for type: HotkeyType) {
        print("Starting to record hotkey for \(type)")
        resetRecordingStates()
        switch type {
        case .focus:   isRecordingFocusHotkey = true
        case .blocker: isRecordingBlockerHotkey = true
        case .close:   isRecordingCloseHotkey = true
        }
    }

    func stopRecordingHotkey() {
        resetRecordingStates()
    }

    private func resetRecordingStates() {
        isRecordingFocusHotkey = false
        isRecordingBlockerHotkey = false
        isRecordingCloseHotkey = false
    }

    /// Called when capture view detects a combo
    func saveNewHotkey(for type: HotkeyType, hotkey: String) {
     print("Saving new hotkey for \(type): \(hotkey)")
    }

    /*// crude parser (expand later to handle any combo)
    private func parseHotkey(_ hotkey: String) -> (key: Key, modifiers: NSEvent.ModifierFlags)? {
        switch hotkey {
        case "⌥A": return (.a, .option)
        case "⌥C": return (.c, .option)
        case "⌥⎋": return (.escape, .option)
        default: return nil
        }
    }*/
}

// MARK: - Settings model
struct GeneralSettings {
    var focusHotkey: String = "⌥A"
    var blockerHotkey: String = "⌥C"
    var closeHotkey: String = "⌥⎋"

    var focusMinimalDuration: Int = 30
    var blockerMinimalDuration: Int = 15
    var allowedTabsDuringBlocking: Int = 3

    var launchAtStartup: Bool = false
    var showNotifications: Bool = true
    var soundEnabled: Bool = true
    var menuBarIconStyle: MenuBarIconStyle = .default
    var hotkeysEnabled: Bool = true
}

enum HotkeyType { case focus, blocker, close }
enum MenuBarIconStyle: String, CaseIterable { case `default` = "Default", minimal = "Minimal", hidden = "Hidden" }
enum HotkeyAction { case focus, blocker, close, quitHardMode }

// MARK: - Hotkey Capture View
struct HotkeyCaptureView: NSViewRepresentable {
    var onCaptured: (String) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard let chars = event.charactersIgnoringModifiers,
                  let keyChar = chars.uppercased().first else {
                return event
            }

            var combo = ""
            if event.modifierFlags.contains(.command) { combo += "⌘" }
            if event.modifierFlags.contains(.shift)   { combo += "⇧" }
            if event.modifierFlags.contains(.option)  { combo += "⌥" }
            if event.modifierFlags.contains(.control) { combo += "⌃" }

            if event.keyCode == 53 {
                combo += "⎋"
            } else {
                combo += String(keyChar)
            }

            onCaptured(combo)
            return nil
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
