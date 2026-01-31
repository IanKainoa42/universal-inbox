import Observation
import SwiftUI
import Foundation

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
        didSet { draftTextDirty = true }
    }

    private var itemsDirty = false
    private var binsDirty = false
    private var draftTextDirty = false

    // Persistence keys
    private static let itemsKey = "items_v1"
    private static let binsKey = "bins_v1"
    private static let draftTextKey = "draftText_v1"

    init() {
        // Data loading is deferred to `load()`
    }

    func load() async {
        // Prioritize loading draft text (lightweight)
        if let text = UserDefaults.standard.string(forKey: Self.draftTextKey) {
            self.draftText = text
            self.draftTextDirty = false // Reset dirty flag after load
        }

        // Offload heavy JSON decoding to background thread
        await loadHeavyData()
    }

    private func loadHeavyData() async {
        // Use Task.detached to avoid blocking the main actor
        // We capture the keys by value (strings) implicitly or use the static ones if accessible.
        // Static properties are accessible.

        let (loadedItems, loadedBins) = await Task.detached(priority: .userInitiated) {
            let defaults = UserDefaults.standard
            var items: [Item]?
            var bins: [Bin]?

            if let data = defaults.data(forKey: AppState.itemsKey),
               let decoded = try? JSONDecoder().decode([Item].self, from: data) {
                items = decoded
            }

            if let data = defaults.data(forKey: AppState.binsKey),
               let decoded = try? JSONDecoder().decode([Bin].self, from: data) {
                bins = decoded
            }

            return (items, bins)
        }.value

        if let loadedItems {
            self.items = loadedItems
            self.itemsDirty = false
        }

        if let loadedBins {
            self.bins = loadedBins
            self.binsDirty = false
        }

        // Seed initial bins if empty and not loaded
        if self.bins.isEmpty {
            self.bins = [
                Bin(name: "Tasks", description: "Actionable items"),
                Bin(name: "Ideas", description: "Thoughts and concepts"),
                Bin(name: "Read/Watch", description: "Content to consume"),
            ]
            self.binsDirty = true // New bins need saving
        }
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

        if draftTextDirty {
            defaults.set(draftText, forKey: Self.draftTextKey)
            draftTextDirty = false
        }
    }

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
    }
}
