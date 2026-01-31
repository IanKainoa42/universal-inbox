import SwiftUI

struct BinsView: View {
    @Environment(AppState.self) private var appState
    @State private var routingTrigger = 0

    var inboxItems: [Item] {
        appState.items.filter { $0.status == .inbox }
            .sorted(by: { $0.createdAt > $1.createdAt })
    }

    var body: some View {
        List {
            Section("Inbox") {
                if inboxItems.isEmpty {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Inbox Empty")
                            .font(.headline)
                        Text("Captured items will appear here.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(inboxItems) { item in
                        Text(item.rawText)
                            .lineLimit(1)
                            .contextMenu {
                                Text("Move to...")
                                ForEach(appState.bins) { bin in
                                    Button {
                                        withAnimation {
                                            appState.moveItem(item, to: bin)
                                            routingTrigger += 1
                                        }
                                    } label: {
                                        Label(bin.name, systemImage: "folder")
                                    }
                                }
                                Divider()
                                Button("Delete", role: .destructive) {
                                    withAnimation {
                                        appState.deleteItem(item)
                                    }
                                }
                            }
                    }
                }
            }

            Section("Bins") {
                if appState.bins.isEmpty {
                    ContentUnavailableView("No Bins", systemImage: "folder.badge.questionmark")
                } else {
                    ForEach(appState.bins) { bin in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(bin.name)
                                    .font(.headline)
                                Text(bin.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(appState.items.filter { $0.binId == bin.id }.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Bins")
        .sensoryFeedback(.success, trigger: routingTrigger)
    }
}

#Preview {
    NavigationStack {
        BinsView()
            .environment(AppState())
    }
}
