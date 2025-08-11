import SwiftUI

struct FocusView: View {
    @ObservedObject var controller: FocusController
    @EnvironmentObject var hardModeManager: HardModeManager

    var body: some View {
        VStack(spacing: 15) {
            Text("Focus Timer")
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(controller.timerMinutes) min")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            HStack(spacing: 15) {
                Button(action: {
                    controller.decreaseBy5()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                        Text("-5")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    controller.decreaseBy15()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                        Text("-15")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    controller.increaseBy5()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                        Text("+5")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    controller.increaseBy15()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("+15")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Timer button - hidden in hardmode when running
            if !(hardModeManager.isHardMode && controller.isTimerRunning) {
                Button(action: {
                    if !controller.isTimerRunning {
                        controller.startTimer()
                    } else {
                        controller.stopTimer()
                    }
                }) {
                    HStack {
                        Image(systemName: controller.isTimerRunning ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(controller.isTimerRunning ? "Stop Timer" : "Start Timer")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(controller.isTimerRunning ? Color.red : Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if !controller.isTimerRunning {
                // Hardmode switch
                HStack {
                    Text("Hard Mode")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { hardModeManager.isHardMode },
                        set: { _ in hardModeManager.toggleHardMode() }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                }
                .padding(.horizontal, 10)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
