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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
