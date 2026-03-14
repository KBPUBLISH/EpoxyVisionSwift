import SwiftUI

struct ReferenceGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var images: AdminApiService.ReferenceImagesResponse?
    @State private var loading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView("Loading gallery…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.brandRed)
                        Text(err)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            categorySection("Flake", items: images?.flake ?? [])
                            categorySection("Quartz", items: images?.quartz ?? [])
                            categorySection("Metallic", items: images?.metallic ?? [])
                            categorySection("Solid", items: images?.solid ?? [])
                        }
                        .padding()
                    }
                }
            }
            .background(AppTheme.surfaceDark)
            .navigationTitle("Reference Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.brandRed)
                }
            }
            .task {
                loading = true
                error = nil
                images = await AdminApiService.fetchReferenceImages()
                loading = false
                if isEmpty {
                    error = "No reference images yet. Add some in the admin panel."
                }
            }
        }
    }

    private var isEmpty: Bool {
        let items = (images?.flake ?? []) + (images?.quartz ?? []) + (images?.metallic ?? []) + (images?.solid ?? [])
        return items.isEmpty
    }

    private func categorySection(_ title: String, items: [AdminApiService.ReferenceItem]) -> some View {
        Group {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(items, id: \.id) { item in
                            if let urlString = item.url, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        placeholderView
                                    case .empty:
                                        placeholderView
                                    @unknown default:
                                        placeholderView
                                    }
                                }
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    Text(item.name)
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                        .background(
                                            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10)),
                                    alignment: .bottomLeading
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(AppTheme.surfaceCard)
            .frame(height: 100)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(AppTheme.textTertiary)
            }
    }
}
