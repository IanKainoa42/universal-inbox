import SwiftUI

struct CaptureView: View {
    @EnvironmentObject private var appState: AppState
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            TextEditor(text: $appState.draftText)
                .font(.system(size: 18, weight: .regular, design: .default))
                .padding()
                .focused($isFocused)
                .scrollContentBackground(.hidden)  // Makes background transparent/cleaner
        }
        .navigationTitle("")
#if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
#endif
        .onAppear {
            isFocused = true
        }
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CaptureView()
                .environmentObject(AppState())
        }
    }
}
