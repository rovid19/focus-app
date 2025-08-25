import AppKit
import SwiftUI

struct SettingsButton: ViewModifier {
    @State private var isHovering = false
    let opacity: Double
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(opacity == 0.0 ? Color.clear : Color.white.opacity(opacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(isHovering ? 0.2 : 0.1), lineWidth: 1)
                    )
            )
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .buttonStyle(PlainButtonStyle())

    }
}

extension View {
    func settingsButton(opacity: Double = 0.0) -> some View {
        modifier(SettingsButton(opacity: opacity))
    }
}
