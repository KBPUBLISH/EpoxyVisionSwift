import SwiftUI

struct SettingsView: View {
    @Environment(StorageService.self) private var storage
    @State private var showPINEntry = false
    @State private var showAdminPanel = false
    @State private var pinInput = ""
    @State private var pinError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.brandRed, AppTheme.brandDarkRed],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)

                            Text("CRS")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Epoxy Visualize")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("By CRS Floors")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text("Version 1.0.0")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .listRowBackground(AppTheme.surfaceCard)
                }

                Section("General") {
                    Label("Projects: \(storage.projects.count)", systemImage: "folder.fill")
                        .foregroundStyle(.white)
                        .listRowBackground(AppTheme.surfaceCard)
                }

                Section("Administration") {
                    Button {
                        showPINEntry = true
                    } label: {
                        Label("Admin Panel", systemImage: "lock.shield.fill")
                            .foregroundStyle(AppTheme.brandRed)
                    }
                    .listRowBackground(AppTheme.surfaceCard)
                }

                Section("About") {
                    Label("Powered by CRS", systemImage: "building.2.fill")
                        .foregroundStyle(.white)
                        .listRowBackground(AppTheme.surfaceCard)
                }
            }
            .scrollContentBackground(.hidden)
            .background { EpoxyBackgroundView() }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Enter Admin PIN", isPresented: $showPINEntry) {
                SecureField("PIN", text: $pinInput)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) {
                    pinInput = ""
                    pinError = false
                }
                Button("Enter") {
                    Task { @MainActor in
                        let valid: Bool
                        if AdminApiService.hasApi {
                            valid = await AdminApiService.verifyAdminPin(pinInput)
                        } else {
                            valid = pinInput == storage.getAdminPIN()
                        }
                        if valid {
                            pinInput = ""
                            pinError = false
                            showAdminPanel = true
                        } else {
                            pinError = true
                            pinInput = ""
                        }
                    }
                }
            } message: {
                if pinError {
                    Text("Incorrect PIN. Try again.")
                } else {
                    Text("Enter the 4-digit admin PIN to access settings.")
                }
            }
            .sheet(isPresented: $showAdminPanel) {
                AdminPanelView()
            }
        }
    }
}
