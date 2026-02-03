import Observation
import SwiftUI
import Foundation

@MainActor
@Observable
class AppState {
    // SECURITY NOTE:
    // This app handles user data which may be sensitive.
    // 1. Data Storage: Currently using UserDefaults for simplicity.
    //    TODO: Migrate to a more secure storage solution (e.g., Encrypted CoreData or SwiftData with FileProtection)
    //    before production release to ensure user privacy and data security.
    // 2. AI Integration: When integrating with OpenAI or other AI providers:
    //    - Ensure API keys are stored securely in Keychain (implemented).
    //    - Do not send PII (Personally Identifiable Information) to the AI service unless strictly necessary and with user consent.
    //    - Review the AI provider's data retention policy.

    var items: [Item] = []
    var bins: [Bin] = []
    var draftText: String = ""
    var openAIKey: String = ""

    // Persistence keys (Local only)
    private let draftTextKey = "draftText_v1"
    private let apiKeyService = "com.universalinbox.openai"
    private let apiKeyAccount = "openai_api_key"

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
            draftDirty = false
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

        // Load API Key from Keychain
        if let data = KeychainHelper.standard.read(service: "com.universalinbox.openai", account: "apikey"),
           let key = String(data: data, encoding: .utf8) {
            // Set backing storage directly to avoid triggering didSet save
            self.openAIKey = key
        }
    }

    func save() {
        // Only saving local state (draftText) here.
        // Items/Bins are saved immediately via their own methods now.
        let defaults = UserDefaults.standard
        defaults.set(draftText, forKey: draftTextKey)

        // Save API Key to Keychain
        if !openAIKey.isEmpty, let data = openAIKey.data(using: .utf8) {
            KeychainHelper.standard.save(data, service: apiKeyService, account: apiKeyAccount)
        } else if openAIKey.isEmpty {
            KeychainHelper.standard.delete(service: apiKeyService, account: apiKeyAccount)
        }
    }

    // Sanitize user input
    func sanitize(text: String) -> String {
        // Basic sanitization: trim whitespace and newlines
        // Future improvements could include stripping control characters if necessary
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Actions

    func createItem(text: String) {
        let newItem = Item(rawText: text)
        items.insert(newItem, at: 0)
        Task {
            await cloudKitManager.saveItem(newItem)
        }
    }

    // MARK: - Actions

    func captureItem(text: String) async throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "com.universalinbox", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot capture empty item"])
        }

        // Simulate network/processing delay
        try await Task.sleep(for: .seconds(0.5))

        let newItem = Item(rawText: text, status: .inbox)
        items.insert(newItem, at: 0)
        draftText = ""
        save()
    }

    func moveItem(_ item: Item, to bin: Bin) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].binId = bin.id
            items[index].status = .processed
            save()
        }
    }

    func deleteItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            save()
        }
    }

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String, defaults: UserDefaults = .standard) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
        self.defaults = defaults
    }

    func addItem(_ text: String) async throws {
        // Simulate async operation
        try await Task.sleep(for: .seconds(0.5))

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.emptyText
        }

        let item = Item(rawText: trimmed)
        items.insert(item, at: 0)
        draftText = ""
        save()
    }

    func deleteItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            save()
        }
    }
}

enum AppError: LocalizedError {
    case emptyText

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Please enter some text."
        }
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
