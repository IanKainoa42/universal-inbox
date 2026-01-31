import Observation
import SwiftUI

@Observable
class AppState {
    var items: [Item] = []
    var bins: [Bin] = []
    var draftText: String = ""

    // Persistence keys
    private let itemsKey = "items_v1"
    private let binsKey = "bins_v1"
    private let draftTextKey = "draftText_v1"

    init() {
        load()
    }

    func load() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: itemsKey),
            let decoded = try? JSONDecoder().decode([Item].self, from: data)
        {
            items = decoded
        }

        if let data = defaults.data(forKey: binsKey),
            let decoded = try? JSONDecoder().decode([Bin].self, from: data)
        {
            bins = decoded
        }

        if let text = defaults.string(forKey: draftTextKey) {
            draftText = text
        }

        // Seed initial bins if empty (optional, helpful for testing)
        if bins.isEmpty {
            bins = [
                Bin(name: "Tasks", description: "Actionable items"),
                Bin(name: "Ideas", description: "Thoughts and concepts"),
                Bin(name: "Read/Watch", description: "Content to consume"),
            ]
        }
    }

    func save() {
        let defaults = UserDefaults.standard

        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: itemsKey)
        }

        if let encoded = try? JSONEncoder().encode(bins) {
            defaults.set(encoded, forKey: binsKey)
        }

        defaults.set(draftText, forKey: draftTextKey)
    }

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
    }
}
