import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: phase - 0.3),
                        .init(color: AppTheme.brandRed.opacity(0.3), location: phase),
                        .init(color: .clear, location: phase + 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)
            }
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}
