# Mission 03: AI Classification with OpenAI

## Objective

Add OpenAI-powered classification that parses the scratch note into discrete items and routes each to the appropriate user-defined bin.

## Context

Read `docs/PRD.md` for product context. The app now has capture (Mission 01) and CloudKit sync (Mission 02). This mission adds the AI brain that makes routing automatic.

## Deliverables

### 1. OpenAI Service
Create `OpenAIService.swift`:
```swift
class OpenAIService {
    private let apiKey: String

    init(apiKey: String)

    /// Parse scratch note into discrete items and classify each
    func classifyItems(
        scratchNote: String,
        bins: [Bin],
        recentCorrections: [Correction]
    ) async throws -> [ClassifiedItem]
}

struct ClassifiedItem {
    let rawText: String
    let suggestedBinId: UUID
    let confidence: Double // 0.0 - 1.0
}
```

### 2. Classification Prompt Engineering

**System Prompt:**
```
You are a personal assistant that categorizes captured thoughts into user-defined bins.

The user has these bins:
{bins with names and descriptions}

Recent corrections (learn from these):
{recent corrections showing original vs correct bin}

Parse the scratch note into discrete items. Each item is a separate thought, task, idea, or note. Then classify each item into the most appropriate bin.

Respond in JSON format:
{
  "items": [
    {"text": "extracted item text", "binId": "uuid", "confidence": 0.95},
    ...
  ]
}
```

**Parsing Rules:**
- Split by line breaks, bullet points, or natural thought boundaries
- Keep each item atomic (one thought per item)
- Preserve original wording
- If unclear which bin, use lowest confidence score

### 3. API Configuration
- Store API key securely in Keychain (not UserDefaults)
- Use GPT-4o-mini for cost efficiency
- Set reasonable token limits
- Handle rate limiting gracefully

### 4. Settings View Update
Add to SettingsView:
- OpenAI API key input (secure field)
- "Test Classification" button
- Show API usage/cost estimate

### 5. Classification Manager
Create `ClassificationManager.swift`:
```swift
@Observable
class ClassificationManager {
    private let openAI: OpenAIService
    private let cloudKit: CloudKitManager

    /// Classify all pending items in scratch note
    func processNote(_ note: String) async throws -> [ClassifiedItem]

    /// Apply classification results (update items in CloudKit)
    func applyClassifications(_ items: [ClassifiedItem]) async throws

    /// Record a correction for learning
    func recordCorrection(item: Item, from: Bin, to: Bin) async throws
}
```

### 6. Error Handling
- Network errors: Queue for retry
- Invalid API key: Show settings prompt
- Rate limit: Exponential backoff
- Parse errors: Log and skip item (don't lose data)

## NOT in Scope
- Background processing trigger (Mission 04)
- UI animations for processing (Mission 04)
- Streaming responses
- Local/on-device models

## Success Criteria
- [ ] Can enter API key in Settings
- [ ] Scratch note with 5 items classifies into correct bins (>80% accuracy)
- [ ] Corrections are stored and influence future classifications
- [ ] Handles API errors gracefully (no crashes, user feedback)
- [ ] Cost per classification < $0.01 for typical note

## Files to Create/Modify
```
UniversalInbox/
├── Services/
│   ├── OpenAIService.swift (new)
│   ├── ClassificationManager.swift (new)
│   └── KeychainManager.swift (new)
├── Views/
│   └── SettingsView.swift (update)
├── State/
│   └── AppState.swift (add classification state)
└── Config/
    └── APIConfig.swift (new - constants, prompts)
```

## API Details

**Endpoint:** `https://api.openai.com/v1/chat/completions`

**Model:** `gpt-4o-mini`

**Estimated Costs:**
- Input: ~$0.15 per 1M tokens
- Output: ~$0.60 per 1M tokens
- Typical note (500 chars + bins): ~200 tokens = $0.00003

**Request Format:**
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "Scratch note:\n{note}"}
  ],
  "response_format": {"type": "json_object"},
  "temperature": 0.3
}
```

## Notes
- Use `response_format: json_object` for reliable parsing
- Low temperature (0.3) for consistent classification
- Include 3-5 recent corrections in prompt for learning
- Test with edge cases: empty note, single word, very long note
