import SwiftUI

struct CaptureView: View {
    @Environment(AppState.self) private var appState
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            TextEditor(text: Bindable(appState).draftText)
                .font(.system(size: 18, weight: .regular, design: .default))
                .padding()
                .focused($isFocused)
                .scrollContentBackground(.hidden)  // Makes background transparent/cleaner
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
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
