import SwiftUI

struct HotkeysSection: View {
    @EnvironmentObject var controller: GeneralSettingsController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Keyboard Shortcuts", description: "Customize hotkeys for quick access")

            VStack(spacing: 12) {
                HotkeyRow(
                    title: "Open Focus Session",
                    description: "Start a new focus session",
                    hotkey: controller.settings.focusHotkey,
                    isRecording: controller.isRecordingFocusHotkey,
                    onStartRecording: { controller.startRecordingHotkey(for: .focus) },
                    onStopRecording: { controller.stopRecordingHotkey() }
                )

                HotkeyRow(
                    title: "Open Blocker Session",
                    description: "Start a new blocking session",
                    hotkey: controller.settings.blockerHotkey,
                    isRecording: controller.isRecordingBlockerHotkey,
                    onStartRecording: { controller.startRecordingHotkey(for: .blocker) },
                    onStopRecording: { controller.stopRecordingHotkey() }
                )

                HotkeyRow(
                    title: "Close Menu Bar Popup",
                    description: "Close the app window",
                    hotkey: controller.settings.closeHotkey,
                    isRecording: controller.isRecordingCloseHotkey,
                    onStartRecording: { controller.startRecordingHotkey(for: .close) },
                    onStopRecording: { controller.stopRecordingHotkey() }
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}