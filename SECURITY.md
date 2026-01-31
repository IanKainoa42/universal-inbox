# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

Please report vulnerabilities by emailing [security@universalinbox.com](mailto:security@universalinbox.com).

## Security Audit & Best Practices

This document outlines the security architecture and best practices for Universal Inbox.

### 1. Data Storage

*   **Current State**:
    *   **User Data (Items/Bins)**: Persisted to the Application Support directory using **Data Protection** (`.completeFileProtection`). This ensures data is encrypted at rest while the device is locked.
    *   **OpenAI API Key**: Stored securely in the iOS/macOS Keychain using `KeychainHelper`. It is never logged or stored in plain text configuration files.

*   **Future/Production Requirements**:
    *   Migrate bulk data storage (Items) to **CloudKit Private Database** or **Encrypted CoreData** for syncing capabilities.
    *   Maintain encryption at rest for all local caches.

### 2. Input Validation

*   **Sanitization**: All user input via `CaptureView` is passed through `InputValidator` to strip control characters and limit length (max 10,000 chars) before being processed.
*   **API Usage**: When sending data to OpenAI, ensure strict prompt engineering to prevent injection attacks (though the risk is lower as the output is structured classification).

### 3. CloudKit Security (Planned)

*   **Private Database**: User data must be stored in the CloudKit Private Database (`CKContainer.default().privateCloudDatabase`). This ensures that even the developer cannot access user data.
*   **Asset Encryption**: If attachments are supported, use `CKAsset` with encryption enabled if available or client-side encryption.

### 4. Privacy

*   **Manifest**: The app includes a `PrivacyInfo.xcprivacy` manifest declaring usage of `UserDefaults` and User Content collection.
*   **Data Minimization**: We only collect what is needed for the app to function (the notes you write).
*   **Third Party**: Data is sent to OpenAI for processing. Users must be informed of this in the Privacy Policy.

### 5. API Keys

*   **Hardcoding**: No API keys are hardcoded in the codebase.
*   **User Provisioning**: Users provide their own OpenAI API Key via the Settings screen, which is saved to Keychain.
