import Observation
import SwiftUI

@Observable
class AppState {
    var items: [Item] = []
    var bins: [Bin] = []
    var draftText: String = ""

    // API Key (in-memory cache)
    var openAIKey: String = "" {
        didSet {
            // Save to Keychain whenever updated
            if !openAIKey.isEmpty {
                if let data = openAIKey.data(using: .utf8) {
                    KeychainHelper.standard.save(data, service: "com.universalinbox.openai", account: "apikey")
                }
            } else {
                KeychainHelper.standard.delete(service: "com.universalinbox.openai", account: "apikey")
            }
        }
    }

    // Persistence keys
    private let itemsKey = "items_v1"
    private let binsKey = "bins_v1"
    private let draftTextKey = "draftText_v1"

    init() {
        load()
    }

    func load() {
        // Load from encrypted file storage
        if let loadedItems: [Item] = loadFromFile(key: itemsKey) {
            items = loadedItems
        }

        if let loadedBins: [Bin] = loadFromFile(key: binsKey) {
            bins = loadedBins
        }

        if let loadedDraft: String = loadFromFile(key: draftTextKey) {
            draftText = loadedDraft
        }

        // Seed initial bins if empty (optional, helpful for testing)
        if bins.isEmpty {
            bins = [
                Bin(name: "Tasks", description: "Actionable items"),
                Bin(name: "Ideas", description: "Thoughts and concepts"),
                Bin(name: "Read/Watch", description: "Content to consume"),
            ]
        }

        // Load API Key from Keychain
        if let data = KeychainHelper.standard.read(service: "com.universalinbox.openai", account: "apikey"),
           let key = String(data: data, encoding: .utf8) {
            // Set backing storage directly to avoid triggering didSet save
            self.openAIKey = key
        }
    }

    func save() {
        // Attempt to capture draft text if present
        if !draftText.isEmpty {
            do {
                let sanitizedText = try InputValidator.validateAndSanitize(draftText)
                let item = Item(rawText: sanitizedText)
                items.append(item)
                draftText = "" // Clear draft on success
            } catch {
                print("Draft validation failed: \(error). Saving as draft.")
                // Keep draftText as is
            }
        }

        // Save to encrypted file storage
        saveToFile(items, key: itemsKey)
        saveToFile(bins, key: binsKey)
        saveToFile(draftText, key: draftTextKey)
    }

    // MARK: - File Storage Helper

    private func getFileURL(for key: String) -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        // Ensure directory exists
        try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)

        return documentsDirectory.appendingPathComponent(key + ".json")
    }

    private func saveToFile<T: Encodable>(_ data: T, key: String) {
        do {
            let url = getFileURL(for: key)
            let encoded = try JSONEncoder().encode(data)
            // .completeFileProtection ensures the file is encrypted while the device is locked
            try encoded.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save \(key): \(error)")
        }
    }

    private func loadFromFile<T: Decodable>(key: String) -> T? {
        let url = getFileURL(for: key)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
    }

    // MARK: - Actions

    func captureItem(_ text: String) {
        do {
            let sanitizedText = try InputValidator.validateAndSanitize(text)
            let item = Item(rawText: sanitizedText)
            items.append(item)
            // In a real app, trigger sync/processing here
        } catch {
            print("Validation failed: \(error)")
        }
    }
}
