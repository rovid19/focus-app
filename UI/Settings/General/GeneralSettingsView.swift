import SwiftUI

struct GeneralSettingsView: View {
        @EnvironmentObject var controller: GeneralSettingsController

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hotkeys Section
                HotkeysSection()

                // Session Settings Section
                SessionSettingsSection()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Hotkeys Section

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

// MARK: - Session Settings Section

struct SessionSettingsSection: View {
    @EnvironmentObject var controller: GeneralSettingsController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Session Configuration", description: "Configure session defaults and limits")

            VStack(spacing: 12) {
                DurationSettingRow(
                    title: "Focus Session Minimal Duration",
                    description: "Minimum time for focus sessions",
                    value: controller.settings.focusMinimalDuration,
                    unit: "minutes",
                    range: 5 ... 120,
                    onChange: { newValue in
                        controller.settings.focusMinimalDuration = newValue
                    }
                )

                DurationSettingRow(
                    title: "Blocker Session Minimal Duration",
                    description: "Minimum time for blocking sessions",
                    value: controller.settings.blockerMinimalDuration,
                    unit: "minutes",
                    range: 5 ... 60,
                    onChange: { newValue in
                        controller.settings.blockerMinimalDuration = newValue
                    }
                )

                TabLimitSettingRow(
                    title: "Allowed Tabs During Blocking",
                    description: "Maximum browser tabs allowed during blocking sessions",
                    value: controller.settings.allowedTabsDuringBlocking,
                    range: 1 ... 3,
                    onChange: { newValue in
                        controller.settings.allowedTabsDuringBlocking = newValue
                    }
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

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Inter-Regular", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))

            Text(description)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Hotkey Row

struct HotkeyRow: View {
    let title: String
    let description: String
    let hotkey: String
    let isRecording: Bool
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Text(description)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            HotkeyInput(
                hotkey: hotkey,
                isRecording: isRecording,
                onStartRecording: onStartRecording,
                onStopRecording: onStopRecording
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Hotkey Input

struct HotkeyInput: View {
    @EnvironmentObject var controller: GeneralSettingsController
    let hotkey: String
    let isRecording: Bool
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    let onCaptured: ((String) -> Void)? = nil // 👈 default

    var body: some View {
        ZStack {
            Button(action: isRecording ? onStopRecording : onStartRecording) {
                HStack(spacing: 6) {
                    if isRecording {
                        Text("Press keys...")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.orange.opacity(0.9))
                    } else {
                        Text(hotkey)
                            .font(.custom("Inter-Regular", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Image(systemName: isRecording ? "stop.circle" : "keyboard")
                        .font(.system(size: 12))
                        .foregroundColor(isRecording ? .orange.opacity(0.8) : .white.opacity(0.6))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isRecording ? Color.orange.opacity(0.1) : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isRecording ? Color.orange.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())

            // 👇 This will actually capture keys while recording
            if isRecording {
                HotkeyCaptureView { combo in
                    print("Captured: \(combo)")
                    onCaptured?(combo) // forward to controller
                }
                .environmentObject(controller)
                .frame(width: 0, height: 0) // invisible but active
            }
        }
        .onAppear {
            print("isRecording", isRecording)
        }
    }
}

// MARK: - Duration Setting Row

struct DurationSettingRow: View {
    let title: String
    let description: String
    let value: Int
    let unit: String
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Text(description)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            DurationPicker(
                value: value,
                unit: unit,
                range: range,
                onChange: onChange
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tab Limit Setting Row

struct TabLimitSettingRow: View {
    let title: String
    let description: String
    let value: Int
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Text(description)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            TabLimitPicker(
                value: value,
                range: range,
                onChange: onChange
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Duration Picker

struct DurationPicker: View {
    let value: Int
    let unit: String
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: {
                if value > range.lowerBound {
                    onChange(value - 5)
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value <= range.lowerBound)

            Text("\(value) \(unit)")
                .font(.custom("Inter-Regular", size: 12))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .frame(minWidth: 80)

            Button(action: {
                if value < range.upperBound {
                    onChange(value + 5)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value >= range.upperBound)
        }
    }
}

// MARK: - Tab Limit Picker

struct TabLimitPicker: View {
    let value: Int
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: {
                if value > range.lowerBound {
                    onChange(value - 1)
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value <= range.lowerBound)

            Text("\(value) tab\(value == 1 ? "" : "s")")
                .font(.custom("Inter-Regular", size: 12))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .frame(minWidth: 60)

            Button(action: {
                if value < range.upperBound {
                    onChange(value + 1)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value >= range.upperBound)
        }
    }
}
