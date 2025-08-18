import SwiftUI

struct LoaderView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Animated dots loader
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("Loading...")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .defaultBackgroundStyle()
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Alternative Loader Styles

struct SpinnerLoader: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    .linear(duration: 1.0)
                    .repeatForever(autoreverses: false),
                    value: isRotating
                )
            
            Text("Loading...")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .defaultBackgroundStyle()
        .onAppear {
            isRotating = true
        }
    }
}

struct PulseLoader: View {
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 12, height: 12)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }
            
            Text("Loading...")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .defaultBackgroundStyle()
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LoaderView()
        SpinnerLoader()
        PulseLoader()
    }
    .padding()
    .background(Color.black)
}
