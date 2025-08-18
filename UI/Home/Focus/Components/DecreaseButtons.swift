import SwiftUI

struct DecreaseButtons: View {
    @ObservedObject var controller: FocusController
   

    var body: some View {
        VStack(spacing: 8) {
            // -15
            Button(action: { controller.decreaseBy15() }) {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Image(systemName: "chevron.left")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 44, height: 44)
                .defaultBackgroundStyle()
            }
            .buttonStyle(TimerControlButtonStyle())

            // -5
            Button(action: { controller.decreaseBy5() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 44, height: 44)
                .defaultBackgroundStyle()
            }
            .buttonStyle(TimerControlButtonStyle())
        }
        .frame(width: controller.shouldHideControls ? 0 : 44, height: 44 * 2 + 8) // lock container height
        .opacity(controller.shouldHideControls ? 0 : 1)
        .clipped()
        .animation(.spring(response: 1.5, dampingFraction: 1), value: controller.shouldHideControls)
    }
}
