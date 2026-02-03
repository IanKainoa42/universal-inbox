import SwiftUI

struct CaptureView: View {
    @Environment(AppState.self) private var appState
    @State private var text: String = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successTrigger = 0

    var body: some View {
        VStack {
            TextEditor(text: Bindable(appState).draftText)
                .font(.system(size: 18, weight: .regular, design: .default))
                .padding()
                .focused($isFocused)
                .scrollContentBackground(.hidden)  // Makes background transparent/cleaner
                .disabled(isLoading)

            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await capture()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            #if os(iOS)
                            .tint(.white)
                            #endif
                    } else {
                        Text("Capture")
                            .bold()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isLoading || appState.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
                .padding()
            }
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            text = appState.draftText
        }
        .onChange(of: isLoading) { _, newValue in
            if !newValue {
                isFocused = true
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .sensoryFeedback(.success, trigger: successTrigger)
        .sensoryFeedback(.error, trigger: showError)
    }

    private func capture() async {
        isLoading = true
        do {
            try await appState.addItem(appState.draftText)
            successTrigger += 1
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        CaptureView()
            .environment(AppState())
    }
}
