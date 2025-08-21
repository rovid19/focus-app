import SwiftUI

// MARK: - FocusView (root)

struct FocusView: View {
    @ObservedObject var controller: FocusController
    @State private var timerRowVisible = false
    @State private var hardModeToggleVisible = false

    var body: some View {
        let isSessionRunning: Bool = controller.isSessionRunning
        let isTimerRunning: Bool = controller.homeController.isTimerRunning

        VStack(spacing: 12) {
            TimerRow(controller: controller)
                .opacity(timerRowVisible ? 1 : 0)
                .offset(y: timerRowVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6), value: timerRowVisible)

            if !controller.shouldHideControls {
                HardModeToggle(controller: controller)
                    .opacity(hardModeToggleVisible ? 1 : 0)
                    .offset(y: hardModeToggleVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: hardModeToggleVisible)
            }
        }
        /*.padding(.horizontal, !isSessionRunning && !isTimerRunning ? 24
            : (isSessionRunning && !isTimerRunning ? 24 : 0))
        .padding(.horizontal, isSessionRunning && !isTimerRunning ? 12
            : (isSessionRunning && !isTimerRunning ? 12 : 0))*/
        .animation(.easeInOut(duration: 0.4), value: controller.isTimerLimited)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .onAppear {
            animateElements()
        }
        // .background(Color.blue)
    }

    private func animateElements() {
        withAnimation(.easeOut(duration: 0.3)) {
            timerRowVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                hardModeToggleVisible = true
            }
        }
    }
}

// MARK: - Row with arrows + timer card

private struct TimerRow: View {
    @ObservedObject var controller: FocusController

    var body: some View {
        HStack(spacing: controller.shouldHideControls ? 0 : 12) {
            DecreaseButtons(controller: controller)
            TimerCard(controller: controller)
            IncreaseButtons(controller: controller)
        }
        .animation(.easeInOut(duration: 0.8), value: controller.shouldHideControls)
    }
}

// MARK: - Styles

struct ButtonHoverEffect: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? Color.white.opacity(0.15) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .opacity(isHovered ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(configuration.isOn ? Color.white.opacity(0.15) : Color.white.opacity(0.1))
                        .frame(width: 48, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(configuration.isOn ? 0.2 : 0.15), lineWidth: 1)
                        )

                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.3), value: configuration.isOn)
                }
            }
        }
        .glassy()
    }
}
