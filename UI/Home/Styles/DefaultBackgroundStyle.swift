import SwiftUI

struct DefaultBackgroundStyle: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func defaultBackgroundStyle(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(DefaultBackgroundStyle(cornerRadius: cornerRadius))
    }
}
