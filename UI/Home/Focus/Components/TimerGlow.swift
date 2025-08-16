import SwiftUI

struct TimerGlow: View {
    @ObservedObject var controller: FocusController
    @State private var opacity: Double = 0.0

    private var shouldAnimate: Bool {
        controller.isSessionRunning && controller.isTimerActive
    }

    var body: some View {
        ZStack {
            // Soft wide glow
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cyan.opacity(opacity * 0.6), lineWidth: 18)
                .blur(radius: 24)
                .mask(RoundedRectangle(cornerRadius: 16))

            // Medium glow
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cyan.opacity(opacity * 0.8), lineWidth: 12)
                .blur(radius: 14)
                .mask(RoundedRectangle(cornerRadius: 16))

            // Sharp core edge
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cyan.opacity(opacity), lineWidth: 4)
                .blur(radius: 4)
                .mask(RoundedRectangle(cornerRadius: 16))
        }
        .allowsHitTesting(false)
        .onAppear {
            if shouldAnimate { startBreathing() }
        }
        .onChange(of: shouldAnimate) { newValue in
            if newValue {
                startBreathing()
            } else {
                stopBreathing()
            }
        }
    }

    private func startBreathing() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            opacity = 1.0
        }
    }

    private func stopBreathing() {
        withAnimation(.easeOut(duration: 0.4)) {
            opacity = 0.0
        }
    }
}
