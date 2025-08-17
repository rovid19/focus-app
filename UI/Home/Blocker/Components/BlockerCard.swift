import SwiftUI

// MARK: - Main BlockerCard

struct BlockerCard: View {
    @ObservedObject var controller: BlockerController

    var body: some View {
        VStack(spacing: 0) {
            BlockerTitle()
            BlockerTimerDisplay(controller: controller)
            BlockerActionButton(controller: controller)
      
        }
        .padding(32)
         .frame(maxWidth: .infinity)
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
            .font(.custom("Inter-Regular", size: 12))
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

    var body: some View {
        VStack(spacing: 4) {
            Text(controller.formattedTimeLeft(from: blockerManager.isRunning ? blockerManager.remainingTime : controller.selectedHours * 3600))
                .font(.custom("Inter-Regular", size: 48))
                .tracking(-0.5)

            if blockerManager.hardLocked && blockerManager.isRunning {
                Text("Hard Mode Active")
                    .font(.custom("Inter-Regular", size: 12))
                    .padding(.horizontal, 8)
                    //.padding(.vertical, 4)
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
                    .font(.custom("Inter-Regular", size: 14))
                Text(blockerManager.isRunning ? "Stop" : "Start Blocker")
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}
