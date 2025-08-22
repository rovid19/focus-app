import SwiftUI


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
        .onAppear {
            print("HotkeyRow onAppear", isRecording)
            print("hotkey", hotkey)
            print("title", title)
            print("description", description)
            print("onStartRecording", onStartRecording)
            print("onStopRecording", onStopRecording)
        }
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
