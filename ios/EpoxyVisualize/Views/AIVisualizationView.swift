import SwiftUI

struct AIVisualizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StorageService.self) private var storage
    @State private var vizService = VisualizationService()
    @State private var showResult1 = false
    @State private var showResult2 = false
    @State private var selectedImage: UIImage?
    @State private var showingBeforeAfter = true

    let originalImage: UIImage
    let epoxyType: EpoxyType
    let styleName: String

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.surfaceDark.ignoresSafeArea()

                if vizService.isGenerating {
                    loadingView
                } else if let error = vizService.errorMessage {
                    errorView(error)
                } else {
                    resultsView
                }
            }
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
            .fullScreenCover(item: $selectedImage) { image in
                ResultDetailView(
                    image: image,
                    epoxyType: epoxyType,
                    styleName: styleName,
                    originalImage: originalImage
                )
            }
            .task {
                await vizService.generateVisualization(
                    originalImage: originalImage,
                    epoxyType: epoxyType,
                    styleName: styleName
                )
                saveProject()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 32) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.surfaceCard)
                    .frame(height: 220)
                    .shimmer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .strokeBorder(AppTheme.borderSubtle, lineWidth: 3)
                            .frame(width: 64, height: 64)

                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(AppTheme.brandRed, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 64, height: 64)
                            .rotationEffect(.degrees(vizService.isGenerating ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: vizService.isGenerating)

                        Image(systemName: "wand.and.stars")
                            .font(.title2)
                            .foregroundStyle(AppTheme.brandRed)
                    }

                    VStack(spacing: 8) {
                        Text("Creating Your Vision")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("AI is transforming your floor with \(styleName)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 32)

            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.brandRed.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .shimmer()
                }
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.brandRed)

            Text("Generation Failed")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await vizService.generateVisualization(
                        originalImage: originalImage,
                        epoxyType: epoxyType,
                        styleName: styleName
                    )
                }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.brandRed)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Visualization")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("\(epoxyType.rawValue) — \(styleName)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.brandRed)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                if showingBeforeAfter {
                    beforeImageCard
                }

                if let img1 = vizService.generatedImage1 {
                    generatedImageCard(img1, label: "Visualization 1")
                }

                if let img2 = vizService.generatedImage2 {
                    generatedImageCard(img2, label: "Visualization 2")
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    private var beforeImageCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ORIGINAL")
                .font(.caption2.bold())
                .foregroundStyle(AppTheme.textTertiary)
                .padding(.horizontal)

            Color(AppTheme.surfaceCard)
                .frame(height: 200)
                .overlay {
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
        }
    }

    private func generatedImageCard(_ image: UIImage, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption2.bold())
                .foregroundStyle(AppTheme.brandRed)
                .padding(.horizontal)

            Button {
                selectedImage = image
            } label: {
                Color(AppTheme.surfaceCard)
                    .frame(height: 240)
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(alignment: .bottomTrailing) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.caption2)
                            Text("Tap to view")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(12)
                    }
            }
            .padding(.horizontal)
        }
    }

    private func saveProject() {
        var project = EpoxyProject(
            epoxyType: epoxyType,
            styleName: styleName,
            originalImageData: originalImage.jpegData(compressionQuality: 0.6)
        )
        if let img1 = vizService.generatedImage1 {
            project.generatedImageData1 = img1.jpegData(compressionQuality: 0.7)
        }
        if let img2 = vizService.generatedImage2 {
            project.generatedImageData2 = img2.jpegData(compressionQuality: 0.7)
        }
        storage.saveProject(project)
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: Int { hashValue }
}
