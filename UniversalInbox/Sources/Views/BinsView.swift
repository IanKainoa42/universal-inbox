import SwiftUI

struct BinsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            Section("Inbox") {
                // Explicitly use id: \.id for stable identity if bins list changes or reloads
                ForEach(appState.bins, id: \.id) { bin in
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

#Preview {
    NavigationStack {
        BinsView()
            .environment(AppState())
    }
}
