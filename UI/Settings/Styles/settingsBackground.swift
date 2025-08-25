import SwiftUI

struct SettingsBackground: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(opacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func settingsBackground(opacity: Double = 0.05) -> some View {
        modifier(SettingsBackground(opacity: opacity))
    }
}
