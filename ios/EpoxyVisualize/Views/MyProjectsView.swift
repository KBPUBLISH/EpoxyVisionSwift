import SwiftUI
import MessageUI

struct MyProjectsView: View {
    @Environment(StorageService.self) private var storage
    @State private var selectedProject: EpoxyProject?

    var body: some View {
        NavigationStack {
            Group {
                if storage.projects.isEmpty {
                    emptyState
                } else {
                    projectGrid
                }
            }
            .background { EpoxyBackgroundView() }
            .navigationTitle("My Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $selectedProject) { project in
                ProjectDetailSheet(project: project)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Projects Yet", systemImage: "photo.stack")
                .foregroundStyle(AppTheme.textSecondary)
        } description: {
            Text("Take a photo and create your first floor visualization")
                .foregroundStyle(AppTheme.textTertiary)
        }
    }

    private var projectGrid: some View {
        ScrollView {
            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(storage.projects) { project in
                    Button {
                        selectedProject = project
                    } label: {
                        projectCard(project)
                    }
                }
            }
            .padding()
        }
    }

    private func projectCard(_ project: EpoxyProject) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let data = project.generatedImageData1, let uiImage = UIImage(data: data) {
                Color(AppTheme.surfaceElevated)
                    .frame(height: 130)
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.surfaceElevated)
                    .frame(height: 130)
                    .overlay {
                        Image(systemName: project.epoxyType.icon)
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(project.styleName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: project.epoxyType.icon)
                        .font(.caption2)
                    Text(project.epoxyType.rawValue)
                        .font(.caption2)
                }
                .foregroundStyle(AppTheme.brandRed)

                Text(project.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.horizontal, 4)
        }
        .padding(10)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.borderSubtle, lineWidth: 0.5)
        )
    }
}

struct ProjectDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StorageService.self) private var storage
    let project: EpoxyProject
    @State private var showDeleteAlert = false
    @State private var squareFootageText: String = ""
    @State private var estimate: QuoteBreakdown?
    @State private var showShareSheet = false
    @State private var showRequestQuoteMail = false
    @State private var showMailUnavailableAlert = false

    private var squareFootage: Double {
        Double(squareFootageText) ?? 0
    }

    private var settings: AdminSettings {
        storage.adminSettings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    projectHeader
                        .padding(.bottom, 24)

                    estimateCreatorSection
                        .padding(.bottom, 20)

                    if let estimate {
                        estimateResultSection(estimate)
                            .padding(.bottom, 20)
                    }

                    deleteButton
                        .padding(.bottom, 32)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .background(AppTheme.surfaceDark)
            .navigationTitle("Estimate Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.brandRed)
                }
            }
            .alert("Delete Project?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    storage.deleteProject(project)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
            .sheet(isPresented: $showShareSheet) {
                if let estimate {
                    ShareSheet(items: [buildEstimateText(estimate)])
                }
            }
            .sheet(isPresented: $showRequestQuoteMail) {
                if let estimate {
                    RequestQuoteMailSheet(
                        project: project,
                        estimate: estimate,
                        squareFootage: squareFootage,
                        onDismiss: { showRequestQuoteMail = false }
                    )
                }
            }
            .alert("Mail Unavailable", isPresented: $showMailUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please configure Mail in Settings to request a quote.")
            }
            .onAppear {
                if let sqft = project.squareFootage {
                    squareFootageText = "\(Int(sqft))"
                }
            }
        }
    }

    private var projectHeader: some View {
        VStack(spacing: 14) {
            if let data = project.generatedImageData1, let img = UIImage(data: data) {
                Color(AppTheme.surfaceCard)
                    .frame(height: 180)
                    .overlay {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 14))
            }

            HStack(spacing: 10) {
                Image(systemName: project.epoxyType.icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.brandRed)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.brandRed.opacity(0.15))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(project.styleName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(project.epoxyType.rawValue)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Text(project.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.horizontal, 4)
        }
    }

    private var estimateCreatorSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "ruler.fill")
                    .foregroundStyle(AppTheme.brandRed)
                Text("PROJECT ESTIMATE")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.textSecondary)
                    .tracking(1.2)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Enter Square Footage")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.dashed")
                            .foregroundStyle(AppTheme.textTertiary)
                        TextField("0", text: $squareFootageText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        Text("sq ft")
                            .font(.subheadline.bold())
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(14)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(.rect(cornerRadius: 12))
                }
            }

            Button {
                guard squareFootage > 0 else { return }
                withAnimation(.spring(duration: 0.5)) {
                    estimate = settings.calculateQuote(sqft: squareFootage, type: project.epoxyType)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                    Text("Generate Estimate")
                        .fontWeight(.bold)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    squareFootage > 0 ? AppTheme.brandRed : AppTheme.surfaceElevated
                )
                .clipShape(.rect(cornerRadius: 14))
            }
            .disabled(squareFootage <= 0)
            .sensoryFeedback(.impact(weight: .heavy), trigger: estimate?.total)
        }
        .padding(16)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.borderSubtle, lineWidth: 0.5)
        )
    }

    private func estimateResultSection(_ estimate: QuoteBreakdown) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(AppTheme.brandRed)
                    Text("ESTIMATE BREAKDOWN")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.textSecondary)
                        .tracking(1.2)
                    Spacer()
                }

                VStack(spacing: 12) {
                    productRow(
                        icon: project.epoxyType.icon,
                        name: "\(project.epoxyType.rawValue) Material",
                        detail: "\(String(format: "%.0f", squareFootage)) sq ft × \(settings.pricePerSqFt(for: project.epoxyType).formatted(.currency(code: "USD")))/sq ft",
                        value: estimate.materialCost
                    )

                    productRow(
                        icon: "percent",
                        name: "Material Upcharge",
                        detail: "\(Int(settings.materialUpchargePercent))% markup",
                        value: estimate.materialUpcharge
                    )

                    productRow(
                        icon: "wrench.and.screwdriver.fill",
                        name: "Labor",
                        detail: "\(String(format: "%.0f", squareFootage)) sq ft × \(settings.laborRatePerSqFt.formatted(.currency(code: "USD")))/sq ft",
                        value: estimate.laborCost
                    )
                }
            }
            .padding(16)

            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Subtotal")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                    if estimate.minimumApplied {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption2)
                            Text("Minimum job price applied")
                                .font(.caption2)
                        }
                        .foregroundStyle(.orange)
                    }
                }
                Spacer()
                Text(estimate.subtotal, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(16)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ESTIMATED TOTAL")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(0.8)
                    Text("\(Int(squareFootage)) sq ft — \(project.epoxyType.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Text(estimate.total, format: .currency(code: "USD"))
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.white)
            }
            .padding(16)
            .background(AppTheme.brandRed)

            HStack(spacing: 12) {
                Button {
                    if MFMailComposeViewController.canSendMail(), let estimate {
                        showRequestQuoteMail = true
                    } else if let estimate, let url = mailtoURL(estimate: estimate) {
                        UIApplication.shared.open(url)
                    } else {
                        showMailUnavailableAlert = true
                    }
                } label: {
                    Label("Request Quote", systemImage: "envelope.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.surfaceElevated)
                        .clipShape(.rect(cornerRadius: 12))
                }

                Button {
                    var updated = project
                    updated.squareFootage = squareFootage
                    updated.quoteTotal = estimate.total
                    storage.saveProject(updated)
                } label: {
                    Label("Save Estimate", systemImage: "square.and.arrow.down.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.brandRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.brandRed.opacity(0.15))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(16)
            .background(AppTheme.surfaceCard)

            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.caption2)
                Text("Powered by")
                    .font(.caption2)
                Text("CRS")
                    .font(.caption.bold())
            }
            .foregroundStyle(AppTheme.textTertiary)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surfaceCard.opacity(0.5))
        }
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.borderSubtle, lineWidth: 0.5)
        )
    }

    private func productRow(icon: String, name: String, detail: String, value: Double) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.brandRed)
                .frame(width: 28, height: 28)
                .background(AppTheme.brandRed.opacity(0.1))
                .clipShape(.rect(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
            }

            Spacer()

            Text(value, format: .currency(code: "USD"))
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Label("Delete Project", systemImage: "trash")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }

    private func mailtoURL(estimate: QuoteBreakdown) -> URL? {
        let subject = "Quote Request - \(project.styleName) - \(Int(squareFootage)) sq ft"
        let body = buildEstimateText(estimate)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:calgary@chemtecresinsupply.com?subject=\(subjectEncoded)&body=\(body ?? "")")
    }

    private func buildEstimateText(_ estimate: QuoteBreakdown) -> String {
        """
        CRS FLOORS — Project Estimate
        
        Project: \(project.styleName)
        Type: \(project.epoxyType.rawValue)
        Area: \(Int(squareFootage)) sq ft
        
        Materials: \(estimate.materialCost.formatted(.currency(code: "USD")))
        Material Upcharge (\(Int(settings.materialUpchargePercent))%): \(estimate.materialUpcharge.formatted(.currency(code: "USD")))
        Labor: \(estimate.laborCost.formatted(.currency(code: "USD")))
        
        ESTIMATED TOTAL: \(estimate.total.formatted(.currency(code: "USD")))
        
        Powered by CRS
        """
    }
}

// MARK: - Request Quote Mail
private struct RequestQuoteMailSheet: UIViewControllerRepresentable {
    let project: EpoxyProject
    let estimate: QuoteBreakdown
    let squareFootage: Double
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["calgary@chemtecresinsupply.com"])
        vc.setSubject("Quote Request - \(project.styleName) - \(Int(squareFootage)) sq ft")
        vc.setMessageBody(requestQuoteBody, isHTML: false)
        if let imageData = project.generatedImageData1 {
            vc.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "\(project.styleName.replacingOccurrences(of: " ", with: "_")).jpg")
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    private var requestQuoteBody: String {
        """
        CRS FLOORS — Quote Request
        
        Project: \(project.styleName)
        Type: \(project.epoxyType.rawValue)
        Area: \(Int(squareFootage)) sq ft
        
        Materials: \(estimate.materialCost.formatted(.currency(code: "USD")))
        Material Upcharge: \(estimate.materialUpcharge.formatted(.currency(code: "USD")))
        Labor: \(estimate.laborCost.formatted(.currency(code: "USD")))
        
        ESTIMATED TOTAL: \(estimate.total.formatted(.currency(code: "USD")))
        
        (Project image attached)
        
        Powered by CRS
        """
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            onDismiss()
        }
    }
}

