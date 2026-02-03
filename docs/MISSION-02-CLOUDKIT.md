# Mission 02: Add CloudKit Sync

## Objective

Replace UserDefaults persistence with CloudKit for real sync across iOS and macOS devices.

## Context

Read `docs/PRD.md` for product context and `docs/MISSION-01-SCAFFOLD.md` for what was built in Mission 01. The app now has a basic capture view and local persistence. This mission adds cloud sync.

## Deliverables

### 1. CloudKit Container Setup
- Create CloudKit container: `iCloud.com.universalinbox.app`
- Add CloudKit entitlement to both iOS and macOS targets
- Enable iCloud capability in Xcode

### 2. CloudKit Schema (Record Types)

**Item Record:**
```
- id: String (UUID)
- rawText: String
- status: String (pending/processing/routed)
- binId: String? (reference to Bin)
- createdAt: Date
- processedAt: Date?
```

**Bin Record:**
```
- id: String (UUID)
- name: String
- description: String
- sortOrder: Int
- createdAt: Date
```

**Correction Record (for AI learning):**
```
- id: String (UUID)
- itemId: String
- originalBinId: String
- correctedBinId: String
- timestamp: Date
```

### 3. CloudKit Manager
Create `CloudKitManager.swift`:
```swift
@Observable
class CloudKitManager {
    // CRUD for Items
    func saveItem(_ item: Item) async throws
    func fetchItems() async throws -> [Item]
    func deleteItem(_ item: Item) async throws
    func updateItemStatus(_ item: Item, status: ItemStatus, binId: UUID?) async throws

    // CRUD for Bins
    func saveBin(_ bin: Bin) async throws
    func fetchBins() async throws -> [Bin]
    func deleteBin(_ bin: Bin) async throws

    // Corrections
    func saveCorrection(_ correction: Correction) async throws
    func fetchRecentCorrections(limit: Int) async throws -> [Correction]
}
```

### 4. Sync Strategy
- Use CKDatabase (private database)
- Fetch on app launch
- Save immediately on changes
- Handle offline gracefully (queue changes, sync when online)
- Use CKSubscription for push updates (optional, can defer)

### 5. Update AppState
- Replace UserDefaults with CloudKitManager
- Add loading states
- Handle sync errors gracefully

### 6. Update Models
- Make models conform to CloudKit coding (CKRecordConvertible or manual)
- Add `recordID` property for CloudKit reference

## NOT in Scope
- OpenAI integration (Mission 03)
- Background processing (Mission 04)
- Push notifications for sync
- Conflict resolution UI (just use server wins for now)

## Success Criteria
- [ ] Items sync between iOS Simulator and macOS app
- [ ] Bins sync between devices
- [ ] New items appear on other device within 5 seconds
- [ ] App works offline (queues changes)
- [ ] No data loss on sync

## Files to Create/Modify
```
UniversalInbox/
├── CloudKit/
│   ├── CloudKitManager.swift
│   └── CKRecord+Extensions.swift
├── Models/
│   ├── Item.swift (update for CloudKit)
│   ├── Bin.swift (update for CloudKit)
│   └── Correction.swift (new)
├── State/
│   └── AppState.swift (update to use CloudKitManager)
└── UniversalInbox.entitlements (add CloudKit)
```

## Notes
- Test with two simulators or simulator + real device
- Use CloudKit Dashboard to verify records
- Handle CKError cases (network, quota, etc.)
