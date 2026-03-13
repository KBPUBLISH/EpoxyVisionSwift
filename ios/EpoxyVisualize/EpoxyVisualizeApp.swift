import SwiftUI

@main
struct EpoxyVisualizeApp: App {
    @State private var storage = StorageService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storage)
                .preferredColorScheme(.dark)
        }
    }
}
