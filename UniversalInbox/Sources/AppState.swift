import Observation
import SwiftUI

@Observable
class AppState {
    var items: [Item] = []
    var bins: [Bin] = []
    var draftText: String = ""

    // Persistence keys (Local only)
    private let draftTextKey = "draftText_v1"

    private let cloudKitManager = CloudKitManager.shared

    init() {
        loadLocal()
        Task {
            await loadCloud()
        }
    }

    func loadLocal() {
        let defaults = UserDefaults.standard
        if let text = defaults.string(forKey: draftTextKey) {
            draftText = text
        }
    }

    func loadCloud() async {
        do {
            async let fetchedItems = cloudKitManager.fetchItems()
            async let fetchedBins = cloudKitManager.fetchBins()

            let (itemsResult, binsResult) = try await (fetchedItems, fetchedBins)

            await MainActor.run {
                self.items = itemsResult
                self.bins = binsResult

                // Seed initial bins if empty (and save to Cloud)
                if self.bins.isEmpty {
                    let initialBins = [
                        Bin(name: "Tasks", description: "Actionable items"),
                        Bin(name: "Ideas", description: "Thoughts and concepts"),
                        Bin(name: "Read/Watch", description: "Content to consume"),
                    ]
                    self.bins = initialBins
                    Task {
                        for bin in initialBins {
                            await self.cloudKitManager.saveBin(bin)
                        }
                    }
                }
            }
        } catch {
            print("Error loading from CloudKit: \(error)")
        }
    }

    func save() {
        // Only saving local state (draftText) here.
        // Items/Bins are saved immediately via their own methods now.
        let defaults = UserDefaults.standard
        defaults.set(draftText, forKey: draftTextKey)
    }

    // MARK: - Actions

    func createItem(text: String) {
        let newItem = Item(rawText: text)
        items.insert(newItem, at: 0)
        Task {
            await cloudKitManager.saveItem(newItem)
        }
    }

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
    }
}
