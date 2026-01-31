import SwiftUI

struct BinsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            Section("Inbox") {
                // Show items that are not yet processed/routed?
                // Or is this purely a list of Bins as per name?
                // The requirements say: Navigation structure: CaptureView (default) -> BinsView -> SettingsView
                // It also mentions: "View items by bin after processing"
                // I'll listing bins here.
                ForEach(appState.bins) { bin in
                    BinRowView(bin: bin)
                        .equatable()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Bins")
    }
}

struct BinRowView: View, Equatable {
    let bin: Bin

    var body: some View {
        Text(bin.name)
            .font(.headline)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(bin.name)
            .accessibilityHint("Shows items in the \(bin.name) bin")
    }
}

#Preview {
    NavigationStack {
        BinsView()
            .environment(AppState())
    }
}
