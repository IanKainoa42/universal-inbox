import Observation
import SwiftUI

@MainActor
@Observable
class AppState {
    var items: [Item] = [] {
        didSet { itemsDirty = true }
    }
    var bins: [Bin] = [] {
        didSet { binsDirty = true }
    }
    var draftText: String = "" {
        didSet { draftDirty = true }
    }

    // Dirty flags to optimize save
    private var itemsDirty = false
    private var binsDirty = false
    private var draftDirty = false

    // Persistence keys
    private static let itemsKey = "items_v1"
    private static let binsKey = "bins_v1"
    private static let draftTextKey = "draftText_v1"

    init() {
        // Only load critical data (draft text) synchronously
        loadDraft()

        // Load heavy data asynchronously
        Task {
            await loadData()
        }
    }

    private func loadDraft() {
        if let text = UserDefaults.standard.string(forKey: Self.draftTextKey) {
            draftText = text
            draftDirty = false
        }
    }

    private func loadData() async {
        // Capture keys to use in detached task
        let itemsKey = Self.itemsKey
        let binsKey = Self.binsKey

        let (loadedItems, loadedBins) = await Task.detached(priority: .userInitiated) {
            let defaults = UserDefaults.standard
            var items: [Item] = []
            var bins: [Bin] = []

            if let data = defaults.data(forKey: itemsKey),
               let decoded = try? JSONDecoder().decode([Item].self, from: data) {
                items = decoded
            }

            if let data = defaults.data(forKey: binsKey),
               let decoded = try? JSONDecoder().decode([Bin].self, from: data) {
                bins = decoded
            }

            // Seed initial bins if empty
            if bins.isEmpty {
                bins = [
                    Bin(name: "Tasks", description: "Actionable items"),
                    Bin(name: "Ideas", description: "Thoughts and concepts"),
                    Bin(name: "Read/Watch", description: "Content to consume"),
                ]
            }

            return (items, bins)
        }.value

        self.items = loadedItems
        self.bins = loadedBins

        // Reset dirty flags as we just loaded the data
        self.itemsDirty = false
        self.binsDirty = false
    }

    func save() {
        let defaults = UserDefaults.standard

        if itemsDirty {
            if let encoded = try? JSONEncoder().encode(items) {
                defaults.set(encoded, forKey: Self.itemsKey)
                itemsDirty = false
            }
        }

        if binsDirty {
            if let encoded = try? JSONEncoder().encode(bins) {
                defaults.set(encoded, forKey: Self.binsKey)
                binsDirty = false
            }
        }

        if draftDirty {
            defaults.set(draftText, forKey: Self.draftTextKey)
            draftDirty = false
        }
    }

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
    }
}
