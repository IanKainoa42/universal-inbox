import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("General") {
                Text("Settings placeholder")
                    .accessibilityLabel("Settings placeholder")
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
    }
}
