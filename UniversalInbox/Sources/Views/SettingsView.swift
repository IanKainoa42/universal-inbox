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
            }

            Section("About") {
                Text("Universal Inbox v0.1")
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
