import SwiftUI

struct IncreaseButtons: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        VStack(spacing: 8) {
            // +15
            Button(action: { controller.increaseBy15() }) {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(TimerControlButtonStyle())
            .disabled(controller.isHardMode && controller.shouldHideControls)
            .opacity((controller.isHardMode && controller.shouldHideControls) ? 0.5 : 1.0)

            // +5
            Button(action: { controller.increaseBy5() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(TimerControlButtonStyle())
            .disabled(controller.isHardMode && controller.shouldHideControls)
            .opacity((controller.isHardMode && controller.shouldHideControls) ? 0.5 : 1.0)
        }
        .frame(width: controller.shouldHideControls ? 0 : 44, height: 44 * 2 + 8, alignment: .trailing) // fixed height
        .clipped()
        .animation(.spring(response: 1.5, dampingFraction: 1), value: controller.shouldHideControls)
    }
}
