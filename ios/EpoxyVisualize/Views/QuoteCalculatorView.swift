import SwiftUI

struct QuoteCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StorageService.self) private var storage
    let epoxyType: EpoxyType
    let styleName: String
    @State private var squareFootageText: String = ""
    @State private var quote: QuoteBreakdown?
    @State private var showShareSheet = false

    private var squareFootage: Double {
        Double(squareFootageText) ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    inputSection
                    if let quote {
                        breakdownSection(quote)
                    }
                }
                .padding()
                .padding(.bottom, 40)
            }
            .background(AppTheme.surfaceDark)
            .navigationTitle("Instant Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let quote {
                    ShareSheet(items: [buildQuoteText(quote)])
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: epoxyType.icon)
                    .foregroundStyle(AppTheme.brandRed)
                Text(epoxyType.rawValue)
                    .foregroundStyle(AppTheme.brandRed)
            }
            .font(.subheadline.bold())

            Text(styleName)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FLOOR AREA")
                .font(.caption2.bold())
                .foregroundStyle(AppTheme.textTertiary)

            HStack(spacing: 12) {
                HStack {
                    TextField("0", text: $squareFootageText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundStyle(.white)

                    Text("sq ft")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.surfaceCard)
                .clipShape(.rect(cornerRadius: 14))

                Button {
                    guard squareFootage > 0 else { return }
                    withAnimation(.spring(duration: 0.4)) {
                        quote = storage.adminSettings.calculateQuote(sqft: squareFootage, type: epoxyType)
                    }
                } label: {
                    Image(systemName: "equal.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.brandRed)
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: quote?.total)
            }
        }
    }

    private func breakdownSection(_ quote: QuoteBreakdown) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                lineItem("Materials", value: quote.materialCost)
                lineItem("Material Upcharge (\(Int(storage.adminSettings.materialUpchargePercent))%)", value: quote.materialUpcharge)
                lineItem("Labor", value: quote.laborCost)

                Divider()
                    .background(AppTheme.borderSubtle)

                HStack {
                    Text("Subtotal")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text(quote.subtotal, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }

                if quote.minimumApplied {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption2)
                        Text("Minimum job price applied")
                            .font(.caption2)
                    }
                    .foregroundStyle(.orange)
                }
            }
            .padding()

            HStack {
                Text("TOTAL")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(quote.total, format: .currency(code: "USD"))
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(AppTheme.brandRed)
            }
            .padding()
            .background(AppTheme.surfaceElevated)

            Button {
                showShareSheet = true
            } label: {
                Label("Share Quote", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.brandRed)
            }
        }
        .clipShape(.rect(cornerRadius: 16))
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func lineItem(_ label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value, format: .currency(code: "USD"))
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
    }

    private func buildQuoteText(_ quote: QuoteBreakdown) -> String {
        """
        CRS FLOORS — Instant Quote
        
        Epoxy Type: \(quote.epoxyType.rawValue)
        Style: \(styleName)
        Area: \(Int(quote.squareFootage)) sq ft
        
        Materials: \(quote.materialCost.formatted(.currency(code: "USD")))
        Labor: \(quote.laborCost.formatted(.currency(code: "USD")))
        
        TOTAL: \(quote.total.formatted(.currency(code: "USD")))
        
        Powered by CRS
        """
    }
}
