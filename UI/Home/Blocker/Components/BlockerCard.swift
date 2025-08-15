import SwiftUI

// MARK: - Main BlockerCard

struct BlockerCard: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        VStack(spacing: 12) {
            BlockerTitle()
            BlockerDurationPicker(controller: controller)
            BlockerTimerDisplay(controller: controller)
            BlockerActionButton(controller: controller)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Title

struct BlockerTitle: View {
    var body: some View {
        Text("BLOCKER")
            .font(.system(size: 11, weight: .medium))
            .tracking(0.8)
            .foregroundColor(.white.opacity(0.55))
    }
}

// MARK: - Duration Picker

struct BlockerDurationPicker: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        VStack(spacing: 6) {
            Text("Duration (hours)")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            Picker("Duration (hours)", selection: $controller.selectedHours) {
                ForEach(1 ... 8, id: \.self) { h in
                    Text("\(h) hour\(h == 1 ? "" : "s")").tag(h)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    
}

// MARK: - Timer Display

struct BlockerTimerDisplay: View {
    @ObservedObject var controller: BlockerController
    @EnvironmentObject var blockerManager: BlockerManager

    var body: some View {
        VStack(spacing: 4) {
            Text(controller.formattedTimeLeft(from: blockerManager.isRunning ? controller.remainingTime : controller.selectedHours * 3600))
                .font(.system(size: 40, weight: .semibold))
                .tracking(-0.5)

            if blockerManager.hardLocked && blockerManager.isRunning {
                Text("Hard Mode Active")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
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

    var body: some View {
        Button(action: {
            controller.toggleBlocker()
        }) {
            HStack(spacing: 8) {
                Image(systemName: blockerManager.isRunning ? "pause" : "play")
                    .font(.system(size: 14))
                Text(blockerManager.isRunning ? "Stop" : "Start Blocker")
                    .font(.system(size: 13, weight: .medium))
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}
