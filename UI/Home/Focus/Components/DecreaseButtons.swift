import SwiftUI

struct DecreaseButtons: View {
    @ObservedObject var controller: FocusController
    @EnvironmentObject var hardModeManager: HardModeManager

    var body: some View {
        VStack(spacing: 8) {
            // -15
            Button(action: { controller.decreaseBy15() }) {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Image(systemName: "chevron.left")
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

            // -5
            Button(action: { controller.decreaseBy5() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
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
        }
        .frame(width: controller.isTimerRunning ? 0 : 44, height: 44 * 2 + 8) // lock container height
        .opacity(controller.isTimerRunning ? 0 : 1)
        .clipped()
        .animation(.spring(response: 0.8, dampingFraction: 1), value: controller.isTimerRunning)
    }
}