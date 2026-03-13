import SwiftUI

struct SolidColorSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let originalImage: UIImage
    @State private var selectedColor: SolidColorOption?
    @State private var showVisualization = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Solid Colors")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 8)

                    Text("Choose a single-tone finish")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(SolidColorOption.presets) { option in
                            Button {
                                selectedColor = option
                                showVisualization = true
                            } label: {
                                solidColorCard(option)
                            }
                            .sensoryFeedback(.selection, trigger: selectedColor?.id)
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
                if let color = selectedColor {
                    AIVisualizationView(
                        originalImage: originalImage,
                        epoxyType: .solidColor,
                        styleName: color.name
                    )
                }
            }
        }
    }

    private func solidColorCard(_ option: SolidColorOption) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(option.color)
                .frame(width: 56, height: 56)
                .overlay {
                    Circle()
                        .strokeBorder(
                            selectedColor?.id == option.id ? AppTheme.brandRed : AppTheme.borderSubtle,
                            lineWidth: selectedColor?.id == option.id ? 3 : 1
                        )
                }
                .shadow(color: option.color.opacity(0.3), radius: 4, y: 2)

            Text(option.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
        }
    }
}
