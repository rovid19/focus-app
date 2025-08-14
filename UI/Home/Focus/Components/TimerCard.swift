import SwiftUI

struct TimerCard: View {
    @ObservedObject var controller: FocusController
    @EnvironmentObject var hardModeManager: HardModeManager

    var body: some View {
        let hideCTA = hardModeManager.isHardMode && controller.isSessionRunning

        VStack(spacing: 0) {
            TitleSection(controller: controller)

            TimerActionButton(controller: controller)
                .frame(height: hideCTA ? 0 : nil, alignment: .top)
                .clipped()
                .animation(.easeInOut(duration: 0.8), value: hideCTA)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .layoutPriority(1)
        .background(CardBackground())
        .animation(.spring(response: 0.8, dampingFraction: 1), value: controller.isSessionRunning)
        .overlay(TimerGlow())
    }
}

// MARK: - Subviews

private struct TitleSection: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        VStack(spacing: 8) {
            Text("FOCUS TIME")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.55))
                .textCase(.uppercase)

            Text(
                controller.isTimerLimited
                    ? "\(controller.timerMinutes):00"
                    : (!controller.isSessionRunning ? "No Time Limit" : "\(controller.timerMinutes):00")
            )
            .font(.system(size: controller.isTimerLimited ? 48 : 24, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
            .tracking(-1.0)
        }
    }
}

private struct TimerActionButton: View {
    @ObservedObject var controller: FocusController
    private var isTimerRunning: Bool {
        controller.isTimerRunning
    }

    private var isSessionRunning: Bool {
        controller.isSessionRunning
    }

    var body: some View {
        HStack {
            Button(action: {
                if !isSessionRunning, !isTimerRunning {
                    Task { await controller.startTimer() }
                } else if isSessionRunning, !isTimerRunning {
                    Task { await controller.startTimer() }
                } else {
                    controller.stopTimer()
                }
            }) {
                Label(isSessionRunning && isTimerRunning ? "Pause" : isSessionRunning && !isTimerRunning ? "Resume" : "Start", systemImage: isSessionRunning ? "pause" : "play")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())

            if controller.isSessionRunning {
                Button(action: controller.terminateSession) {
                    Label("Stop", systemImage: "stop")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

private struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
