import SwiftUI

// MARK: - Glass Window Style
struct GlassWindowStyle: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Glass Background Styles
struct GlassBackgroundStyle: ViewModifier {
    let material: Material
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
         /*content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.black.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        */content
            .background(material, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

struct LegacyGlassBackgroundStyle: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

// Note: GlassButtonStyle is defined in UI/Home/Styles/GlassButtonStyle.swift

// MARK: - Glass Tab Button Style
struct GlassTabButtonStyle: ButtonStyle {
    let isActive: Bool
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .environment(\.isHovered, isHovered)
    }
}

// MARK: - Glassy Modifier
struct GlassyModifier: ViewModifier {
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Environment Key for Hover State
private struct IsHoveredKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isHovered: Bool {
        get { self[IsHoveredKey.self] }
        set { self[IsHoveredKey.self] = newValue }
    }
}

// MARK: - Extension for convenience
extension View {
    func glassWindow(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(GlassWindowStyle(cornerRadius: cornerRadius))
    }
    
    func glassBackground(material: Material = .ultraThinMaterial, cornerRadius: CGFloat = 12) -> some View {
        self.modifier(GlassBackgroundStyle(material: material, cornerRadius: cornerRadius))
    }
    
    func legacyGlassBackground(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(LegacyGlassBackgroundStyle(cornerRadius: cornerRadius))
    }
    
    func glassy(paddingHorizontal: CGFloat = 12, paddingVertical: CGFloat = 8, cornerRadius: CGFloat = 8) -> some View {
        self.modifier(GlassyModifier(paddingHorizontal: paddingHorizontal, paddingVertical: paddingVertical, cornerRadius: cornerRadius))
    }
}
