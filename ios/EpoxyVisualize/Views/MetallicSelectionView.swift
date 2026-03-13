import SwiftUI

struct MetallicSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let originalImage: UIImage
    @State private var selectedStyle: MetallicStyle?
    @State private var showVisualization = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Metallic Designs")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 8)

                    Text("Choose a pearlescent finish")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(MetallicStyle.presets) { style in
                            Button {
                                selectedStyle = style
                                showVisualization = true
                            } label: {
                                metallicCard(style)
                            }
                            .sensoryFeedback(.selection, trigger: selectedStyle?.id)
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
                if let style = selectedStyle {
                    AIVisualizationView(
                        originalImage: originalImage,
                        epoxyType: .metallic,
                        styleName: style.name
                    )
                }
            }
        }
    }

    private func metallicCard(_ style: MetallicStyle) -> some View {
        VStack(spacing: 10) {
            ZStack {
                LinearGradient(
                    colors: style.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 110)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear, .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(.rect(cornerRadius: 12))
                }

                if selectedStyle?.id == style.id {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.brandRed, lineWidth: 3)
                        .frame(height: 110)
                }
            }

            Text(style.name)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(8)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 16))
    }
}
