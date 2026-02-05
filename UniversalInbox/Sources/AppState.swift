import Foundation
import Observation

/// Shared observable state for the app UI and persistence coordination.
@MainActor
@Observable
final class AppState {
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

    private let defaults: UserDefaults
    private let cloudKitManager: CloudKitManager

    // Persistence keys (Local only)
    private let draftTextKey = "draftText_v1"
    private let apiKeyService = "com.universalinbox.openai"
    private let apiKeyAccount = "openai_api_key"

    init(
        defaults: UserDefaults = .standard,
        cloudKitManager: CloudKitManager = .shared,
        loadCloud: Bool = true
    ) {
        self.defaults = defaults
        self.cloudKitManager = cloudKitManager
        loadLocal()
        if loadCloud {
            Task {
                await loadCloud()
            }
        } else {
            seedInitialBinsIfNeeded()
        }
    }

    /// Loads local-only state (draft text) from UserDefaults.
    func loadLocal() {
        if let text = defaults.string(forKey: draftTextKey) {
            draftText = text
        }
    }

    /// Loads items and bins from CloudKit, then hydrates credentials from Keychain.
    func loadCloud() async {
        do {
            async let fetchedItems = cloudKitManager.fetchItems()
            async let fetchedBins = cloudKitManager.fetchBins()

            let (itemsResult, binsResult) = try await (fetchedItems, fetchedBins)
            items = itemsResult
            bins = binsResult

            if bins.isEmpty {
                seedInitialBinsIfNeeded(saveToCloud: true)
            }
        } catch {
            print("Error loading from CloudKit: \(error)")
        }

        // Load API Key from Keychain
        if let data = KeychainHelper.standard.read(service: apiKeyService, account: apiKeyAccount),
           let key = String(data: data, encoding: .utf8) {
            openAIKey = key
        }
    }

    /// Persists local-only state and credentials.
    func save() {
        // Only saving local state (draftText) here.
        // Items/Bins are saved immediately via their own methods now.
        defaults.set(draftText, forKey: draftTextKey)

        // Save API Key to Keychain
        if !openAIKey.isEmpty, let data = openAIKey.data(using: .utf8) {
            KeychainHelper.standard.save(data, service: apiKeyService, account: apiKeyAccount)
        } else if openAIKey.isEmpty {
            KeychainHelper.standard.delete(service: apiKeyService, account: apiKeyAccount)
        }
    }

    // MARK: - Actions

    /// Adds a new item and persists it to CloudKit.
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
        Task {
            await cloudKitManager.saveItem(item)
        }
        save()
    }

    /// Updates an item's bin and status, then persists it to CloudKit.
    func moveItem(_ item: Item, to bin: Bin) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].binId = bin.id
            items[index].status = .processed
            let updatedItem = items[index]
            Task {
                await cloudKitManager.saveItem(updatedItem)
            }
            save()
        }
    }

    /// Deletes an item locally and in CloudKit.
    func deleteItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            Task {
                await cloudKitManager.deleteItem(item)
            }
            save()
        }
    }

    private func seedInitialBinsIfNeeded(saveToCloud: Bool = false) {
        guard bins.isEmpty else { return }

        let initialBins = [
            Bin(name: "Tasks", description: "Actionable items"),
            Bin(name: "Ideas", description: "Thoughts and concepts"),
            Bin(name: "Read/Watch", description: "Content to consume"),
        ]

        bins = initialBins

        guard saveToCloud else { return }

        Task {
            for bin in initialBins {
                await cloudKitManager.saveBin(bin)
            }
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
}
