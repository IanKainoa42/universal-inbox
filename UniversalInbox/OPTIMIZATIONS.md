# Optimizations

## Goal
Achieve "Capture-to-close" time of under 5 seconds.

## Changes Implemented

### 1. App Launch Optimization (AppState.swift)
- **Split Initialization**: The `AppState` initialization has been split into critical and non-critical paths.
    - `loadDraft()`: Loads the draft text synchronously. This ensures the text editor is populated immediately upon app launch.
    - `loadData()`: Loads `items` and `bins` asynchronously on a background thread (`Task.detached`). This prevents large datasets (JSON decoding) from blocking the main thread during app startup.
- **MainActor Concurrency**: `AppState` is now isolated to the `@MainActor` to ensure UI updates are safe, while heavy lifting (decoding) is offloaded.

### 2. Save Optimization (AppState.swift)
- **Dirty Tracking**: Added `itemsDirty`, `binsDirty`, and `draftDirty` flags.
- **Incremental Save**: The `save()` method now checks these flags and only encodes/writes data that has actually changed.
    - **Impact**: For the primary "Capture" use case (open -> type -> close), only the `draftText` (small string) is written to disk. The potentially large `items` array is skipped, significantly reducing the "close" time and CPU usage.

## Recommended Profiling Instruments

To verify and further tune performance, the following Xcode Instruments are recommended:

### 1. App Launch
- **Instrument**: "App Launch" template.
- **Metric**: Time to First Frame.
- **Goal**: Ensure the first frame appears almost instantly. Verify that `AppState.init` does not show heavy JSON decoding on the Main Thread track.

### 2. Time Profiler
- **Instrument**: "Time Profiler".
- **Scenario**: App Launch and App Backgrounding (Close).
- **Goal**:
    - **Launch**: Confirm `JSONDecoder.decode` happens on a background thread (look for `Task` or `BG` threads).
    - **Close**: Confirm `AppState.save` takes minimal time when only typing text. Verify `JSONEncoder.encode` is NOT called for `items` if no items were modified.

### 3. File Activity
- **Instrument**: "File Activity".
- **Scenario**: App Backgrounding.
- **Goal**: Verify that only `draftText_v1` key (in plist) is being written during a simple capture session.

## Verification Steps
1. **Launch Speed**: Open the app. The `CaptureView` should appear immediately with the keyboard.
2. **Background Data**: If you have many items, they will populate silently in the background (visible if you switch to `BinsView`).
3. **Save Speed**: Type something and background the app. It should feel instant.
