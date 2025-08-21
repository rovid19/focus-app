import HotKey
import SwiftUI

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
        hotkeyManager?.pauseHotkeys()
        resetRecordingStates()
        switch type {
        case .focus: isRecordingFocusHotkey = true
        case .blocker: isRecordingBlockerHotkey = true
        case .close: isRecordingCloseHotkey = true
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
    func saveNewHotkey(for type: HotkeyAction, hotkey: String) {
        hotkeys[type] = parseHotkey(hotkey)
        stopRecordingHotkey()
        hotkeyManager?.registerHotkey(
            focus: hotkeys[.focus] ?? (.a, .option),
            blocker: hotkeys[.blocker] ?? (.c, .option),
            close: hotkeys[.close] ?? (.escape, .option),
            quit: hotkeys[.quitHardMode] ?? (.k, .option)
        )
        updateSettings(for: type, hotkeyString: hotkey)
       // hotkeyManager?.resumeHotkeys()
    }

    private func updateSettings(for type: HotkeyAction, hotkeyString: String) {
        switch type {
        case .focus:
            settings.focusHotkey = hotkeyString
        case .blocker:
            settings.blockerHotkey = hotkeyString
        case .close:
            settings.closeHotkey = hotkeyString
        case .quitHardMode:
            // If you also want to store it
            // add `quitHardModeHotkey` to GeneralSettings
            break
        }
    }

    // crude parser (expand later to handle any combo)
    private func parseHotkey(_ hotkey: String) -> (key: Key, modifiers: NSEvent.ModifierFlags)? {
        var modifiers: NSEvent.ModifierFlags = []
        var key: Key?

        // --- 1. Parse modifiers ---
        if hotkey.contains("⌘") { modifiers.insert(.command) }
        if hotkey.contains("⇧") { modifiers.insert(.shift) }
        if hotkey.contains("⌥") { modifiers.insert(.option) }
        if hotkey.contains("⌃") { modifiers.insert(.control) }

        // --- 2. Remove modifier glyphs to isolate key string ---
        var cleaned = hotkey
            .replacingOccurrences(of: "⌘", with: "")
            .replacingOccurrences(of: "⇧", with: "")
            .replacingOccurrences(of: "⌥", with: "")
            .replacingOccurrences(of: "⌃", with: "")

        // --- 3. Map key ---
        cleaned = cleaned.uppercased()

        if let first = cleaned.first, cleaned.count == 1 {
            // Letters A–Z
            if let scalar = first.unicodeScalars.first,
               let mapped = Key(Character(UnicodeScalar(scalar)))
            {
                key = mapped
            }
        } else {
            // Special keys
            switch cleaned {
            case "⎋": key = .escape
            case " ": key = .space
            case "↩": key = .return
            case "⇥": key = .tab
            // expand with arrows, F1–F12, etc.
            default: break
            }
        }

        guard let resolvedKey = key else { return nil }
        return (resolvedKey, modifiers)
    }
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
    @EnvironmentObject var controller: GeneralSettingsController
    var onCaptured: (String) -> Void

    func makeNSView(context _: Context) -> NSView {
        let view = NSView()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard let chars = event.charactersIgnoringModifiers,
                  let keyChar = chars.uppercased().first
            else {
                return event
            }

            var combo = ""
            if event.modifierFlags.contains(.command) { combo += "⌘" }
            if event.modifierFlags.contains(.shift) { combo += "⇧" }
            if event.modifierFlags.contains(.option) { combo += "⌥" }
            if event.modifierFlags.contains(.control) { combo += "⌃" }

            if event.keyCode == 53 {
                combo += "⎋"
            } else {
                combo += String(keyChar)
            }

            onCaptured(combo)
            controller.saveNewHotkey(for: .focus, hotkey: combo)
            controller.stopRecordingHotkey()

            return nil
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}

extension Key {
    init?(_ character: Character) {
        switch character {
        // Letters
        case "A": self = .a
        case "B": self = .b
        case "C": self = .c
        case "D": self = .d
        case "E": self = .e
        case "F": self = .f
        case "G": self = .g
        case "H": self = .h
        case "I": self = .i
        case "J": self = .j
        case "K": self = .k
        case "L": self = .l
        case "M": self = .m
        case "N": self = .n
        case "O": self = .o
        case "P": self = .p
        case "Q": self = .q
        case "R": self = .r
        case "S": self = .s
        case "T": self = .t
        case "U": self = .u
        case "V": self = .v
        case "W": self = .w
        case "X": self = .x
        case "Y": self = .y
        case "Z": self = .z
        // Numbers
        case "0": self = .zero
        case "1": self = .one
        case "2": self = .two
        case "3": self = .three
        case "4": self = .four
        case "5": self = .five
        case "6": self = .six
        case "7": self = .seven
        case "8": self = .eight
        case "9": self = .nine
        // Whitespace + common symbols
        case " ": self = .space
        case "\t": self = .tab
        case "\r": self = .return
        case "\u{8}": self = .delete // backspace
        // Arrows (use glyphs if you want)
        case "←": self = .leftArrow
        case "→": self = .rightArrow
        case "↑": self = .upArrow
        case "↓": self = .downArrow
        // Escape
        case "⎋": self = .escape
        default:
            return nil
        }
    }
}
