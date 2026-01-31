import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
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
    }
}
