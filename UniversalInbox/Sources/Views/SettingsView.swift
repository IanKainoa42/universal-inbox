import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section("AI Configuration") {
                SecureField("OpenAI API Key", text: Bindable(appState).openAIKey)
                    .textContentType(.password)
            }

            Section("General") {
                Text("Settings placeholder")
                    .accessibilityLabel("Settings placeholder")
            }

            Section("AI Configuration") {
                SecureField("OpenAI API Key", text: Bindable(appState).openAIKey)
                    .textContentType(.password)

                Text("API Key is stored securely in Keychain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                Text("Universal Inbox v0.1")
                    .accessibilityLabel("App version Universal Inbox 0.1")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppState())
    }
}
