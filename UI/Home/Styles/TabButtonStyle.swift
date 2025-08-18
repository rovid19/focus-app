import SwiftUI

struct TabButtonStyle: ButtonStyle {
    let isActive: Bool
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.white.opacity(0.1) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .opacity(isHovered ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
    }
}
