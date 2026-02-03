import SwiftUI

struct BinsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            Section("Inbox") {
                // Show items that are not yet processed/routed?
                // Or is this purely a list of Bins as per name?
                // The requirements say: Navigation structure: CaptureView (default) -> BinsView -> SettingsView
                // It also mentions: "View items by bin after processing"
                // I'll listing bins here.
                ForEach(appState.bins) { bin in
                    Text(bin.name)
                        .font(.headline)
                    // In a real app, this would NavigationLink to a detail view of items in that bin
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Bins")
    }
}

struct BinsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BinsView()
                .environmentObject(AppState())
        }
    }
}
