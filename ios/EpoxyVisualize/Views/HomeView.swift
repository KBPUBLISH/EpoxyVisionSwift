import SwiftUI
import PhotosUI

struct HomeView: View {
    @Environment(StorageService.self) private var storage
    @Binding var selectedTab: Int
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showEpoxySelector = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    actionCards
                    if !storage.projects.isEmpty {
                        recentProjectsSection
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background { EpoxyBackgroundView() }
            .navigationTitle("Epoxy Visualize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .fullScreenCover(isPresented: $showEpoxySelector) {
                if let image = capturedImage {
                    EpoxyTypeSelectorView(originalImage: image)
                }
            }
            .onChange(of: capturedImage) { _, newValue in
                if newValue != nil {
                    showEpoxySelector = true
                }
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        capturedImage = image
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Text("CRS")
                    .font(.system(size: 42, weight: .black, design: .default))
                    .foregroundStyle(AppTheme.brandRed)
                Text(" FLOORS")
                    .font(.system(size: 42, weight: .black, design: .default))
                    .foregroundStyle(.white)
            }

            Text("Visualize your dream floor")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var actionCards: some View {
        HStack(spacing: 16) {
            Button {
                showCamera = true
            } label: {
                actionCard(
                    icon: "camera.fill",
                    title: "Take Photo",
                    subtitle: "Capture your floor"
                )
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                actionCard(
                    icon: "photo.on.rectangle.angled",
                    title: "Upload Photo",
                    subtitle: "From your library"
                )
            }
        }
    }

    private func actionCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.brandRed.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(AppTheme.brandRed)
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.borderSubtle, lineWidth: 1)
        )
    }

    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Projects")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Spacer()
                Button("See All") {
                    selectedTab = 2
                }
                .font(.subheadline)
                .foregroundStyle(AppTheme.brandRed)
            }

            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(storage.projects.prefix(4))) { project in
                    ProjectCardSmall(project: project)
                }
            }
        }
    }
}

struct ProjectCardSmall: View {
    let project: EpoxyProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let data = project.generatedImageData1, let uiImage = UIImage(data: data) {
                Color(AppTheme.surfaceElevated)
                    .frame(height: 100)
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.surfaceElevated)
                    .frame(height: 100)
                    .overlay {
                        Image(systemName: project.epoxyType.icon)
                            .font(.title2)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(project.styleName)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(project.epoxyType.rawValue)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(8)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 14))
    }
}
