import SwiftUI

struct CaptureView: View {
    @Environment(AppState.self) private var appState
    @State private var text: String = ""

    var body: some View {
        VStack {
            DraftEditorView(text: $text)
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            text = appState.draftText
        }
        .onChange(of: text) { _, newValue in
            appState.draftText = newValue
        }
        .onChange(of: appState.draftText) { _, newValue in
            if text != newValue {
                text = newValue
            }
        }
    }
}

struct DraftEditorView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 18, weight: .regular, design: .default))
            .padding()
            .focused($isFocused)
            .scrollContentBackground(.hidden)  // Makes background transparent/cleaner
            .accessibilityLabel("Draft content")
            .accessibilityHint("Enter your thoughts here")
            .onAppear {
                isFocused = true
            }
    }
}

#Preview {
    NavigationStack {
        CaptureView()
            .environment(AppState())
    }
}
