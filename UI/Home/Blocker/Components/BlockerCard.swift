import SwiftUI

// MARK: - Main BlockerCard

struct BlockerCard: View {
    @ObservedObject var controller: BlockerController
    @ObservedObject var blockerManager: BlockerManager

    var body: some View {
        VStack(spacing: 0) {
            BlockerTitle()
            BlockerTimerDisplay(controller: controller)
            BlockerActionButton(controller: controller)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .defaultBackgroundStyle(cornerRadius: 16)
        .overlay(TimerGlowBlocker(controller: blockerManager))
        .animation(.spring(response: 0.8, dampingFraction: 1), value: blockerManager.isRunning)
    }
}

// MARK: - Title

struct BlockerTitle: View {
    var body: some View {
        Text("BLOCKER SESSION")
            .font(.custom("Inter-Regular", size: 8))
            .tracking(1.5)
            .foregroundColor(.white.opacity(0.55))
            .padding(.bottom, 8)
            .textCase(.uppercase)
    }
}

// MARK: - Timer Display

struct BlockerTimerDisplay: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager
    @State private var delayedTime: String = ""

    var body: some View {
        VStack(spacing: 4) {
            let currentTime = controller.formattedTimeLeft(
                from: blockerManager.isRunning
                    ? blockerManager.remainingTime
                    : controller.selectedHours * 3600
            )

            VStack(spacing: 4) {
                Text(delayedTime)
                    .font(.custom("Inter-Regular", size: 48))
                    .tracking(-0.5)
            }
            .onAppear { delayedTime = currentTime }
            .onChange(of: currentTime) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    delayedTime = newValue
                }
            }

            if blockerManager.hardLocked && blockerManager.isRunning {
                Text("Hard Mode Active")
                    .font(.custom("Inter-Regular", size: 12))
                    .padding(.horizontal, 8)
                    // .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }
}

// MARK: - Action Button

struct BlockerActionButton: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager

    @State private var pulseOpacity: Double = 1.0
    @State private var delayedIsRunning: Bool = false
    @State private var isAnimatingClick: Bool = false   // 👈 new local flag

    var body: some View {
        Button(action: {
            // step 1: fade out immediately
            isAnimatingClick = true
            withAnimation(.easeOut(duration: 0.1)) {
                pulseOpacity = 0.0
            }

            // step 2: delay the actual toggle until fade-out has started
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                controller.toggleBlocker()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: delayedIsRunning ? "pause" : "play")
                    .font(.custom("Inter-Regular", size: 14))
                Text(delayedIsRunning ? "Stop" : "Start Blocker")
                    .font(.custom("Inter-Regular", size: 13))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .opacity(pulseOpacity)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            delayedIsRunning = blockerManager.isRunning
        }
        .onChange(of: blockerManager.isRunning) { newValue in
            // only run this when the actual toggle finishes
            if isAnimatingClick {
                delayedIsRunning = newValue
                withAnimation(.easeInOut(duration: 0.8)) {
                    pulseOpacity = 1.0
                }
                isAnimatingClick = false
            } else {
                // normal updates without click (e.g. restore state)
                delayedIsRunning = newValue
            }
        }
    }
}
