import SwiftUI

struct TimerCard: View {
    @ObservedObject var controller: FocusController
    @EnvironmentObject var hardModeManager: HardModeManager

    var body: some View {
        let hideCTA = hardModeManager.isHardMode && controller.isTimerRunning
        let isRunning = controller.isTimerRunning

        VStack(spacing: 0) {
            TitleSection(timerMinutes: controller.timerMinutes)

            TimerActionButton(isRunning: isRunning) {
                if !isRunning {
                    Task { await controller.startTimer() }
                } else {
                    controller.stopTimer()
                }
            }
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
        .animation(.spring(response: 0.8, dampingFraction: 1), value: isRunning)
        .overlay(TimerGlow())
    }
}

// MARK: - Subviews

private struct TitleSection: View {
    let timerMinutes: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("FOCUS TIME")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.55))
                .textCase(.uppercase)

            Text("\(timerMinutes):00")
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .tracking(-1.0)
        }
    }
}

private struct TimerActionButton: View {
    let isRunning: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause" : "play")
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
