import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView(selection: Bindable(appState).activeTab) {
            NavigationStack {
                CaptureView()
            }
            .tag(AppTab.capture)
            .tabItem {
                Label("Capture", systemImage: "square.and.pencil")
            }

            NavigationStack {
                BinsView()
            }
            .tag(AppTab.bins)
            .tabItem {
                Label("Bins", systemImage: "tray.full")
            }

            NavigationStack {
                SettingsView()
            }
            .tag(AppTab.settings)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        // Global keyboard shortcut for New Capture
        .background {
            Button("New Capture") {
                appState.activeTab = .capture
            }
            .keyboardShortcut("n", modifiers: .command)
            .opacity(0)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
