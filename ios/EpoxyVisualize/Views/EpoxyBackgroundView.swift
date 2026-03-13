import SwiftUI

struct EpoxyBackgroundView: View {
    var body: some View {
        ZStack {
            AppTheme.surfaceDark

            Canvas { context, size in
                let w = size.width
                let h = size.height

                let stripes: [(color: Color, opacity: Double, yOffset: CGFloat, amplitude: CGFloat, frequency: CGFloat, thickness: CGFloat)] = [
                    (.white, 0.09, h * 0.08, 35, 1.2, 100),
                    (AppTheme.brandRed, 0.07, h * 0.18, 50, 0.8, 120),
                    (.white, 0.12, h * 0.28, 28, 1.5, 90),
                    (.white, 0.06, h * 0.36, 20, 2.0, 50),
                    (AppTheme.brandRed, 0.05, h * 0.45, 40, 1.0, 100),
                    (.white, 0.10, h * 0.55, 32, 1.3, 80),
                    (AppTheme.brandRed, 0.08, h * 0.65, 55, 0.7, 140),
                    (.white, 0.08, h * 0.72, 22, 1.8, 60),
                    (.white, 0.11, h * 0.80, 25, 1.6, 95),
                    (AppTheme.brandRed, 0.04, h * 0.88, 45, 0.9, 90),
                    (.white, 0.07, h * 0.94, 30, 1.1, 70),
                ]

                for stripe in stripes {
                    var path = Path()
                    let steps = Int(w / 2)
                    for i in 0...steps {
                        let x = CGFloat(i) * 2
                        let progress = x / w
                        let y = stripe.yOffset + sin(progress * .pi * 2 * stripe.frequency) * stripe.amplitude + cos(progress * .pi * 3 * stripe.frequency * 0.7) * stripe.amplitude * 0.4
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y - stripe.thickness / 2))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y - stripe.thickness / 2))
                        }
                    }
                    for i in stride(from: steps, through: 0, by: -1) {
                        let x = CGFloat(i) * 2
                        let progress = x / w
                        let y = stripe.yOffset + sin(progress * .pi * 2 * stripe.frequency) * stripe.amplitude + cos(progress * .pi * 3 * stripe.frequency * 0.7) * stripe.amplitude * 0.4
                        path.addLine(to: CGPoint(x: x, y: y + stripe.thickness / 2))
                    }
                    path.closeSubpath()

                    context.fill(path, with: .color(stripe.color.opacity(stripe.opacity)))
                }

                let shimmerStripes: [(yOffset: CGFloat, width: CGFloat, opacity: Double)] = [
                    (h * 0.10, 3, 0.07),
                    (h * 0.25, 2, 0.06),
                    (h * 0.42, 2.5, 0.08),
                    (h * 0.58, 2, 0.05),
                    (h * 0.72, 3, 0.07),
                    (h * 0.85, 2, 0.06),
                ]
                for shimmer in shimmerStripes {
                    var path = Path()
                    let steps = Int(w / 2)
                    for i in 0...steps {
                        let x = CGFloat(i) * 2
                        let progress = x / w
                        let y = shimmer.yOffset + sin(progress * .pi * 4) * 15 + cos(progress * .pi * 2.5) * 10
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    context.stroke(path, with: .color(.white.opacity(shimmer.opacity)), lineWidth: shimmer.width)
                }
            }
            .blur(radius: 20)

            LinearGradient(
                colors: [
                    AppTheme.surfaceDark.opacity(0.3),
                    .clear,
                    AppTheme.surfaceDark.opacity(0.2),
                    .clear,
                    AppTheme.surfaceDark.opacity(0.4),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}
