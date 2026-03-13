import SwiftUI

struct EpoxyTypeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    let originalImage: UIImage
    @State private var selectedType: EpoxyType?
    @State private var showStyleSelection = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Choose Your\nEpoxy Style")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    Text("Select the type of epoxy coating to visualize")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(EpoxyType.allCases) { type in
                            Button {
                                selectedType = type
                                showStyleSelection = true
                            } label: {
                                epoxyTypeCard(type)
                            }
                            .sensoryFeedback(.impact(weight: .medium), trigger: showStyleSelection)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background { EpoxyBackgroundView() }
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
            .fullScreenCover(isPresented: $showStyleSelection) {
                if let type = selectedType {
                    StyleSelectionRouter(epoxyType: type, originalImage: originalImage)
                }
            }
        }
    }

    private func epoxyTypeCard(_ type: EpoxyType) -> some View {
        VStack(spacing: 14) {
            ZStack {
                LinearGradient(
                    colors: type.previewColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 100)
                .clipShape(.rect(cornerRadius: 12))

                Image(systemName: type.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            }

            VStack(spacing: 4) {
                Text(type.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(type.subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.borderSubtle, lineWidth: 1)
        )
    }
}

struct StyleSelectionRouter: View {
    let epoxyType: EpoxyType
    let originalImage: UIImage

    var body: some View {
        switch epoxyType {
        case .flake:
            FlakeBlendSelectionView(originalImage: originalImage)
        case .metallic:
            MetallicSelectionView(originalImage: originalImage)
        case .quartz:
            QuartzSelectionView(originalImage: originalImage)
        case .solidColor:
            SolidColorSelectionView(originalImage: originalImage)
        }
    }
}
