import SwiftUI

struct TimerCard: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        let hideCTA = controller.isHardMode && controller.shouldHideControls

        VStack(spacing: 0) {
            TitleSection(controller: controller)

            TimerActionButton(controller: controller)
                .frame(height: hideCTA ? 0 : nil, alignment: .top)
                .clipped()
                .animation(.easeInOut(duration: 0.8), value: hideCTA)
        }
        //.padding(.horizontal, 32)
        //.padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .layoutPriority(1)
        .background(CardBackground())
        .animation(.spring(response: 0.8, dampingFraction: 1), value: controller.isTimerLimited)
        .overlay(TimerGlow(controller: controller))
    }
}

// MARK: - Subviews

private struct TitleSection: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        VStack(spacing: 8) {
            Text("FOCUS TIME")
                .font(.custom("Inter-Regular", size: 12))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.55))
                .textCase(.uppercase)

            if controller.isTimerLimited {
                Text("\(controller.homeController.blockerController.formattedTimeLeft(from: controller.timerMinutes))")
                    .font(.custom("Inter_18pt-Medium", size: 48))
                    .foregroundColor(.white)
            } else if !controller.isTimerLimited && controller.isSessionRunning {
                Text("\(controller.homeController.blockerController.formattedTimeLeft(from: controller.timerMinutes))")
                    .font(.custom("Inter_18pt-Medium", size: 48))
                    .foregroundColor(.white)
            } else {
                Text("No time limit")
                    .font(.custom("Inter_18pt-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
            }
            /* .opacity(!controller.isTimerLimited && controller.isSessionRunning ? 0 : 1)
             .animation(.easeInOut(duration: 0.2), value: controller.isSessionRunning) */
        }
    }
}

private struct TimerActionButton: View {
    @ObservedObject var controller: FocusController
    private var isTimerRunning: Bool {
        controller.isTimerActive
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
