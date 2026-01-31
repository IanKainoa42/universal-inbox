import SwiftUI

struct CaptureView: View {
    @Environment(AppState.self) private var appState
    @FocusState private var isFocused: Bool

    @State private var isCapturing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var successTrigger = 0

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                if appState.draftText.isEmpty {
                    Text("What's on your mind?")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }

                TextEditor(text: Bindable(appState).draftText)
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)  // Makes background transparent/cleaner
            }
            .padding()
        }
        .navigationTitle("Capture")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isCapturing {
                    ProgressView()
                } else {
                    Button("Capture") {
                        capture()
                    }
                    .disabled(appState.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sensoryFeedback(.success, trigger: successTrigger)
        .onAppear {
            isFocused = true
        }
        .onChange(of: appState.activeTab) { _, newValue in
            if newValue == .capture {
                isFocused = true
            }
        }
    }

    private func capture() {
        guard !appState.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isCapturing = true

        Task {
            do {
                try await appState.captureItem(text: appState.draftText)
                successTrigger += 1
                isCapturing = false
                isFocused = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isCapturing = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView()
            .environment(AppState())
    }
}
