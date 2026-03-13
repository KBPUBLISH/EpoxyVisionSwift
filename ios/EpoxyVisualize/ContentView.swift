import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(selectedTab: $selectedTab)
            }

            Tab("Projects", systemImage: "square.grid.2x2.fill", value: 2) {
                MyProjectsView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                SettingsView()
            }
        }
        .tint(AppTheme.brandRed)
    }
}
