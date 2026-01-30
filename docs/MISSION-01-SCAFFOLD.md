# Mission 01: Scaffold iOS App with Capture Screen

## Objective

Create the foundational SwiftUI app structure with a working capture screen (scratch note) for iOS and macOS.

## Context

Read `docs/PRD.md` for full product context. This is a universal inbox app where users dump thoughts into a scratch note, and AI automatically routes items to user-defined bins.

## Deliverables

### 1. Xcode Project Structure
- Create SwiftUI app targeting iOS 17+ and macOS 14+
- Use Swift 5.9+
- Project name: `UniversalInbox`
- Bundle ID: `com.universalinbox.app`
- Set up shared code between iOS and macOS targets

### 2. Capture Screen (Main View)
- Full-screen text editor (the "scratch note")
- Minimal UI - just the text area, no chrome
- Placeholder text: "Write anything..."
- Auto-focus on app open
- Support for multiple lines, freeform text

### 3. Basic Navigation Structure
```
App
├── CaptureView (main scratch note - default view)
├── BinsView (list of user bins - empty for now)
└── SettingsView (placeholder)
```

### 4. Data Models (local only for now)
```swift
struct Item: Identifiable {
    let id: UUID
    var rawText: String
    var status: ItemStatus // pending, processing, routed
    var binId: UUID?
    let createdAt: Date
    var processedAt: Date?
}

enum ItemStatus {
    case pending, processing, routed
}

struct Bin: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var sortOrder: Int
    let createdAt: Date
}
```

### 5. Basic State Management
- Use `@Observable` (iOS 17+) or `ObservableObject`
- Create `AppState` class to hold items and bins
- Persist to UserDefaults for now (CloudKit comes later)

## NOT in Scope (for this mission)
- CloudKit integration
- OpenAI integration
- Background processing
- Apple Pencil specific features
- Bin creation UI
- Item routing/disappearing animation

## Success Criteria
- [ ] App builds and runs on iOS Simulator
- [ ] App builds and runs on macOS
- [ ] Can type text in capture view
- [ ] Text persists after app restart (UserDefaults)
- [ ] Navigation to empty Bins and Settings views works

## Files to Create
```
UniversalInbox/
├── UniversalInboxApp.swift
├── Models/
│   ├── Item.swift
│   └── Bin.swift
├── State/
│   └── AppState.swift
├── Views/
│   ├── CaptureView.swift
│   ├── BinsView.swift
│   └── SettingsView.swift
└── UniversalInbox.entitlements
```

## Notes
- Keep it simple - this is the foundation
- Prioritize clean architecture over features
- Use modern Swift patterns (@Observable, async/await where applicable)
