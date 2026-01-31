import Foundation

struct InputValidator {
    static let maxItemLength = 10000 // Reasonable limit for a single note

    enum ValidationError: Error {
        case empty
        case tooLong
    }

    /// Sanitizes and validates the input text.
    /// - Parameter text: The raw text input.
    /// - Returns: Sanitized text if valid.
    /// - Throws: ValidationError if the input is invalid.
    static func validateAndSanitize(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            throw ValidationError.empty
        }

        if trimmed.count > maxItemLength {
            throw ValidationError.tooLong
        }

        // Basic sanitization: Remove control characters that might be problematic
        // This is a basic example; depending on how the text is used (e.g. Markdown rendering),
        // more specific escaping might be needed.
        // We preserve newlines and tabs as they are valid in notes.
        let invalidCharacters = CharacterSet.controlCharacters
            .subtracting(.newlines)
            .subtracting(CharacterSet(charactersIn: "\t"))

        let sanitized = trimmed.components(separatedBy: invalidCharacters).joined()

        return sanitized
    }
}
