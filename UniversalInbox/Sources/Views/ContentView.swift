import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CaptureView()
            }
            .tag(AppTab.capture)
            .tabItem {
                Label("Capture", systemImage: "square.and.pencil")
            }
            .tag(0)

            NavigationStack {
                BinsView()
            }
            .tag(AppTab.bins)
            .tabItem {
                Label("Bins", systemImage: "tray.full")
            }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tag(AppTab.settings)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Capture") {
                    selectedTab = 0
                }
                .keyboardShortcut("n", modifiers: .command)
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
