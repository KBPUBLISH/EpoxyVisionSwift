import SwiftUI

struct AdminPanelView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StorageService.self) private var storage
    @State private var flakePrice: String = ""
    @State private var metallicPrice: String = ""
    @State private var quartzPrice: String = ""
    @State private var solidPrice: String = ""
    @State private var laborRate: String = ""
    @State private var minimumJob: String = ""
    @State private var upchargePercent: String = ""
    @State private var newPIN: String = ""
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Price Per Square Foot") {
                    priceField("Flake", text: $flakePrice, icon: "sparkles")
                    priceField("Metallic", text: $metallicPrice, icon: "diamond.fill")
                    priceField("Quartz", text: $quartzPrice, icon: "cube.fill")
                    priceField("Solid Color", text: $solidPrice, icon: "paintbrush.fill")
                }
                .listRowBackground(AppTheme.surfaceCard)

                Section("Labor & Fees") {
                    priceField("Labor Rate / sq ft", text: $laborRate, icon: "wrench.and.screwdriver.fill")
                    priceField("Minimum Job Price", text: $minimumJob, icon: "dollarsign.circle.fill")
                    HStack {
                        Label("Material Upcharge %", systemImage: "percent")
                            .foregroundStyle(.white)
                        Spacer()
                        TextField("15", text: $upchargePercent)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(AppTheme.brandRed)
                            .frame(width: 80)
                    }
                }
                .listRowBackground(AppTheme.surfaceCard)

                Section("Security") {
                    HStack {
                        Label("Change PIN", systemImage: "lock.fill")
                            .foregroundStyle(.white)
                        Spacer()
                        SecureField("New PIN", text: $newPIN)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(AppTheme.brandRed)
                            .frame(width: 100)
                    }
                }
                .listRowBackground(AppTheme.surfaceCard)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.surfaceDark)
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                    }
                    .foregroundStyle(AppTheme.brandRed)
                    .fontWeight(.bold)
                }
            }
            .onAppear { loadCurrentSettings() }
            .overlay {
                if showSaved {
                    savedBanner
                }
            }
        }
    }

    private func priceField(_ label: String, text: Binding<String>, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 2) {
                Text("$")
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("0.00", text: text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(AppTheme.brandRed)
                    .frame(width: 80)
            }
        }
    }

    private var savedBanner: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Settings Saved")
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.9))
            .clipShape(Capsule())
            .transition(.move(edge: .top).combined(with: .opacity))

            Spacer()
        }
        .padding(.top, 8)
    }

    private func loadCurrentSettings() {
        let s = storage.adminSettings
        flakePrice = String(format: "%.2f", s.flakePricePerSqFt)
        metallicPrice = String(format: "%.2f", s.metallicPricePerSqFt)
        quartzPrice = String(format: "%.2f", s.quartzPricePerSqFt)
        solidPrice = String(format: "%.2f", s.solidColorPricePerSqFt)
        laborRate = String(format: "%.2f", s.laborRatePerSqFt)
        minimumJob = String(format: "%.2f", s.minimumJobPrice)
        upchargePercent = String(format: "%.0f", s.materialUpchargePercent)
    }

    private func saveSettings() {
        let settings = AdminSettings(
            flakePricePerSqFt: Double(flakePrice) ?? 6.50,
            metallicPricePerSqFt: Double(metallicPrice) ?? 9.00,
            quartzPricePerSqFt: Double(quartzPrice) ?? 7.50,
            solidColorPricePerSqFt: Double(solidPrice) ?? 5.00,
            laborRatePerSqFt: Double(laborRate) ?? 3.50,
            minimumJobPrice: Double(minimumJob) ?? 1500.0,
            materialUpchargePercent: Double(upchargePercent) ?? 15.0
        )

        if AdminApiService.hasApi {
            Task { @MainActor in
                let ok = await AdminApiService.saveAdminSettings(
                    currentPIN: storage.getAdminPIN(),
                    newPIN: newPIN.count >= 4 ? newPIN : nil,
                    settings: settings
                )
                if ok {
                    storage.adminSettings = settings
                    if !newPIN.isEmpty && newPIN.count >= 4 {
                        storage.setAdminPIN(newPIN)
                    }
                    showSavedAndDismiss()
                } else {
                    showSavedAndDismiss()
                }
            }
        } else {
            storage.saveAdminSettings(settings)
            if !newPIN.isEmpty && newPIN.count >= 4 {
                storage.setAdminPIN(newPIN)
            }
            showSavedAndDismiss()
        }
    }

    private func showSavedAndDismiss() {
        withAnimation(.spring(duration: 0.3)) {
            showSaved = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showSaved = false
            }
            dismiss()
        }
    }
}
