# Performance Profiling Guide

This document outlines the recommended approach for profiling the Universal Inbox app to ensure the "Capture-to-close" workflow completes in under 5 seconds.

## Instruments

Use Xcode Instruments (Product > Profile, or Command+I) to analyze performance.

### 1. Time Profiler (App Launch & Responsiveness)
- **Goal**: Measure the time spent during app launch and ensure the main thread is not blocked.
- **Scenario**: Launch the app, type a short note in the Capture view, and close the app (background/kill).
- **What to look for**:
  - `UniversalInboxApp.init` or `AppState.init`: Ensure no heavy synchronous work (like JSON decoding) happens here on the main thread.
  - `AttributeGraph`: High CPU usage here might indicate excessive SwiftUI view updates.
  - `Main Thread`: Ensure it's mostly idle waiting for user input.

### 2. SwiftUI View Body (Rendering)
- **Goal**: Verify that views are not re-computing their bodies unnecessarily.
- **Scenario**: Type in the `CaptureView`.
- **What to look for**:
  - High count of body evaluations for `CaptureView` or `ContentView` while typing.
  - Use `Self._printChanges()` inside `body` to debug *why* a view is updating.
  - Ensure `TextEditor` updates don't trigger layout passes for the whole screen if not needed.

### 3. Allocations (Memory)
- **Goal**: Check for memory leaks or retain cycles.
- **Scenario**: Navigate between `CaptureView` and `BinsView` repeatedly.
- **What to look for**:
  - `Persistent Bytes`: Should not grow unbounded.
  - `Leak Checks`: Ensure `AppState` or other objects are not leaked.
  - Verify closures in `AppState` or view modifiers don't capture `self` strongly where weak is appropriate.

## Optimizations to Verify

1. **App Launch**:
   - Verify `AppState.load()` runs asynchronously and doesn't block the UI.
   - `draftText` should appear almost instantly.

2. **Data Loading**:
   - `items` and `bins` decoding happens on a background thread.
   - The UI remains responsive during this process.

3. **Capture Flow**:
   - Typing in `CaptureView` feels smooth (60fps).
   - Closing the app triggers `save()` efficiently. Only modified data should be written to disk.

## Debugging Tips

- Enable `Strict Concurrency Checking` in Build Settings to catch threading issues.
- Use `Task.detached` for heavy non-UI work, but be careful with data races.
- If `List` scrolling is jerky in `BinsView`, ensure `id:` is stable and rows are lightweight.
