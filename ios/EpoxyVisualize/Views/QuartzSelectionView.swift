import SwiftUI

struct QuartzSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let originalImage: UIImage
    @State private var selectedBlend: QuartzBlend?
    @State private var showVisualization = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Quartz Systems")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 8)

                    Text("Choose a natural stone texture")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(QuartzBlend.presets) { blend in
                            Button {
                                selectedBlend = blend
                                showVisualization = true
                            } label: {
                                quartzCard(blend)
                            }
                            .sensoryFeedback(.selection, trigger: selectedBlend?.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background(AppTheme.surfaceDark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showVisualization) {
                if let blend = selectedBlend {
                    AIVisualizationView(
                        originalImage: originalImage,
                        epoxyType: .quartz,
                        styleName: blend.name
                    )
                }
            }
        }
    }

    private func quartzCard(_ blend: QuartzBlend) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.surfaceElevated)
                    .frame(height: 80)

                HStack(spacing: 0) {
                    ForEach(Array(blend.colors.enumerated()), id: \.offset) { _, color in
                        color
                    }
                }
                .clipShape(.rect(cornerRadius: 10))
                .frame(height: 80)
                .overlay {
                    Canvas { context, size in
                        for _ in 0..<40 {
                            let x = CGFloat.random(in: 0...size.width)
                            let y = CGFloat.random(in: 0...size.height)
                            let rect = CGRect(x: x, y: y, width: 2, height: 2)
                            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.15)))
                        }
                    }
                    .clipShape(.rect(cornerRadius: 10))
                }

                if selectedBlend?.id == blend.id {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(AppTheme.brandRed, lineWidth: 3)
                        .frame(height: 80)
                }
            }

            Text(blend.name)
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}
