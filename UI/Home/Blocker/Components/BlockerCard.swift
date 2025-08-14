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
                ForEach(1...8, id: \.self) { h in
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

    var body: some View {
        VStack(spacing: 4) {
            Text(timeString(from: controller.selectedHours * 3600))
                .font(.system(size: 40, weight: .semibold))
                .tracking(-0.5)

            if controller.hardMode && controller.isRunning {
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


   private func timeString(from seconds: Int) -> String {
        let m = max(0, seconds) / 60
        let s = max(0, seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }

}

// MARK: - Action Button
struct BlockerActionButton: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        Button(action: {
            if controller.isRunning {
                controller.stopOrPauseBlocker()
            } else {
                controller.startBlocker()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: controller.isRunning ? "pause" : "play")
                    .font(.system(size: 14))
                Text(controller.isRunning ? "Running..." : "Start Blocker")
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
