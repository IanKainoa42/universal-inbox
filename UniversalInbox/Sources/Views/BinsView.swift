import SwiftUI

struct BinsView: View {
    @Environment(AppState.self) private var appState

    var inboxItems: [Item] {
        appState.items.filter { $0.status == .inbox }
    }

    var body: some View {
        Group {
            if inboxItems.isEmpty && appState.bins.isEmpty {
                ContentUnavailableView {
                    Label("All Caught Up", systemImage: "tray")
                } description: {
                    Text("Capture new items or create bins to get started.")
                }
            } else {
                List {
                    Section {
                        if inboxItems.isEmpty {
                            Text("Inbox is empty")
                                .foregroundStyle(.secondary)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(inboxItems) { item in
                                Text(item.rawText)
                                    .lineLimit(2)
                            }
                            .onDelete(perform: deleteItems)
                        }
                    } header: {
                        Label("Inbox", systemImage: "tray")
                    }

                    Section {
                        if appState.bins.isEmpty {
                            Text("No bins")
                                .foregroundStyle(.secondary)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(appState.bins) { bin in
                                VStack(alignment: .leading) {
                                    Text(bin.name)
                                        .font(.headline)
                                    Text(bin.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } header: {
                        Label("Bins", systemImage: "archivebox")
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Bins")
    }

    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { inboxItems[$0] }
        for item in itemsToDelete {
            appState.deleteItem(item)
        }
    }
}

#Preview {
    NavigationStack {
        BinsView()
            .environment(AppState())
    }
}
