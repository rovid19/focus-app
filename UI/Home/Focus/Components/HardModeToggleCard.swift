import SwiftUI

struct HardModeToggle: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        if controller.isTimerLimited {
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "shield")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hard Mode")
                            .font(.custom("Inter-Regular", size: 14))
                        Text("When enabled, you cannot turn it off or change time while a session is running.")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { controller.isHardMode },
                    set: { _ in controller.toggleHardMode() }
                ))
                .toggleStyle(SwitchToggleStyle())
                .opacity(controller.isHardMode ? 0.6 : 1)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .opacity(controller.shouldHideControls ? 0 : 1)
            .offset(y: controller.shouldHideControls ? 50 : 0) // slide downward
            .clipped()
            .animation(.easeInOut(duration: 0.8), value: controller.shouldHideControls)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
