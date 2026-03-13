import SwiftUI

struct ResultDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let epoxyType: EpoxyType
    let styleName: String
    let originalImage: UIImage
    @State private var showShareSheet = false
    @State private var showQuoteCalculator = false
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.surfaceDark.ignoresSafeArea()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .safeAreaInset(edge: .bottom) {
                actionButtons
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.5))
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(styleName)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                        Text(epoxyType.rawValue)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [image])
            }
            .sheet(isPresented: $showQuoteCalculator) {
                QuoteCalculatorView(epoxyType: epoxyType, styleName: styleName)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    saved = true
                } label: {
                    Label(saved ? "Saved" : "Download", systemImage: saved ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.surfaceElevated)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .sensoryFeedback(.success, trigger: saved)

                Button {
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.surfaceElevated)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }

            Button {
                showQuoteCalculator = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Get Instant Quote")
                        .fontWeight(.bold)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.brandRed)
                .clipShape(.rect(cornerRadius: 14))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: showQuoteCalculator)
        }
        .padding()
        .background(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: AppTheme.surfaceDark.opacity(0.9), location: 0.2),
                    .init(color: AppTheme.surfaceDark, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
