import SwiftUI

struct FlakeBlendSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let originalImage: UIImage
    @State private var selectedBlend: FlakeBlend?
    @State private var showVisualization = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Flake Blends")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 8)

                    Text("Choose a decorative chip blend")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(FlakeBlend.presets) { blend in
                            Button {
                                selectedBlend = blend
                                showVisualization = true
                            } label: {
                                blendCard(blend)
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
                        epoxyType: .flake,
                        styleName: blend.name
                    )
                }
            }
        }
    }

    private func blendCard(_ blend: FlakeBlend) -> some View {
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
                    if selectedBlend?.id == blend.id {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(AppTheme.brandRed, lineWidth: 3)
                    }
                }
            }

            Text(blend.name)
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}
