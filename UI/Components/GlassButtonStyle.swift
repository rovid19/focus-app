import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    @State private var isHovered = false
    let cornerRadius: CGFloat
    let paddingVertical: CGFloat
    let paddingHorizontal: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // 🔹 Base dimmed, brighten on hover
            .font(.custom("Inter-Regular", size: 12))
            .foregroundColor(isHovered ? .white : .white.opacity(0.7))
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(isHovered ? 0.3 : 0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
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

// 🔹 Shortcut
extension Button {
    func glassy(cornerRadius: CGFloat = 8, paddingVertical: CGFloat = 8, paddingHorizontal: CGFloat = 12) -> some View {
        self.buttonStyle(GlassButtonStyle(cornerRadius: cornerRadius, paddingVertical: paddingVertical, paddingHorizontal: paddingHorizontal))
    }
}
