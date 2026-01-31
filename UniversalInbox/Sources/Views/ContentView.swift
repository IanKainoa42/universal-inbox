import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CaptureView()
            }
            .tabItem {
                Label("Capture", systemImage: "square.and.pencil")
            }
            .tag(0)

            NavigationStack {
                BinsView()
            }
            .tabItem {
                Label("Bins", systemImage: "tray.full")
            }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
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
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
