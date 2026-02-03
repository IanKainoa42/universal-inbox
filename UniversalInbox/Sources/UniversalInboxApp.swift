import SwiftUI

@main
struct UniversalInboxApp: App {
    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    // Load data asynchronously when the view appears.
                    // This prevents blocking the app launch on the main thread.
                    await appState.load()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                appState.save()
            }
        }
    }
}
