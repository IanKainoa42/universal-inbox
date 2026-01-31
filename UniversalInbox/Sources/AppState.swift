import Observation
import SwiftUI

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

    // Persistence keys
    private let itemsKey = "items_v1"
    private let binsKey = "bins_v1"
    private let draftTextKey = "draftText_v1"
    private let apiKeyService = "com.universalinbox.openai"
    private let apiKeyAccount = "openai_api_key"

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

        // Load API Key from Keychain
        if let data = KeychainHelper.standard.read(service: apiKeyService, account: apiKeyAccount),
           let key = String(data: data, encoding: .utf8) {
            openAIKey = key
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

        // Input Validation: Sanitize draftText before saving
        draftText = sanitize(text: draftText)
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

    // Initializer for preview/testing
    init(items: [Item], bins: [Bin], draftText: String) {
        self.items = items
        self.bins = bins
        self.draftText = draftText
    }
}
