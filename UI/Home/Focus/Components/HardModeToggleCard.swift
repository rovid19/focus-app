import SwiftUI

struct HardModeToggle: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Hard Mode")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    Text("When enabled, you cannot change time while the timer is running.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { controller.isHardMode },
                set: { _ in controller.toggleHardMode() }
            ))
            .toggleStyle(CustomToggleStyle())
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
    }
}