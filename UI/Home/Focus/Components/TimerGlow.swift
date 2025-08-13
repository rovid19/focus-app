import SwiftUI

struct TimerGlow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.08))
            .blur(radius: 20)
            .scaleEffect(1.2)
            .allowsHitTesting(false)
    }
}