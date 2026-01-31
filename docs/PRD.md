# Universal Inbox - Product Requirements Document

## Product Summary

Universal Inbox is a capture-first productivity app that separates the act of capturing thoughts from the work of organizing them. Users dump anything into a single "scratch note" inbox, then batch-process items with AI-powered classification that routes each item to user-defined categories. The product works WITH existing tools (Obsidian, Notion, Reminders) rather than replacing them.

## Problem Statement

People capture ideas across scattered locations (Apple Notes, voice memos, random text files, messages to self). These captures often go unprocessed because the friction of organizing happens at capture time - when you're busy thinking, not organizing. Ideas get lost, tasks slip through cracks, and the mental overhead of "where does this go?" interrupts the flow of capturing.

## Target User

Knowledge workers and productivity enthusiasts who:
- Use multiple capture tools but struggle with consolidation
- Already have organizational systems (PARA, Notion databases, etc.) but friction in feeding them
- Value quick capture but postpone organization (leading to backlogs)
- Trust AI assistance for low-stakes categorization

## Core Features (MVP)

### 1. Universal Capture
- Single text input, optimized for speed (<5 seconds to capture and close)
- "Scratch note" metaphor - dump anything
- Apple Pencil support on iPad
- Keyboard shortcut / widget for instant access
- Mobile (iOS) + Desktop (macOS)

### 2. Inbox Accumulation
- All captures land in single chronological note
- No organization required at capture time
- Items persist until processed

### 3. Automatic Processing
- **No manual "Process" button** - processing happens automatically
- Triggers: on app close, on idle, or passively in background
- AI parses scratch note into discrete items, classifies each
- Visual feedback: items highlight/gray out while processing, disappear when routed
- Next open: clean slate (or items still mid-process)

### 4. User-Defined Bins
- Users create their own categories (e.g., "Ideas," "Tasks," "Shopping," "Projects")
- Each bin has a description that helps AI classify
- System learns from corrections (user overrides improve future accuracy)

### 5. Routing Behavior
- Items route to bins within the app
- **Items are removed from inbox when routed** (clean as you go)
- View items by bin after processing
- Export/share individual items

## Non-Goals (v1)

- External integrations (Obsidian, Notion, etc.) - v2
- Voice capture - v2
- Image/file capture - v2
- Collaborative features
- Android
- Web app

## Success Criteria

1. Capture-to-close time < 5 seconds
2. AI classification accuracy > 80% after 50 corrections
3. Items processed within 60 seconds of app close
4. Zero inbox residue - items don't pile up (they disappear)

## Open Questions

1. **Correction UX:** How does user override a misclassification? Swipe? Long-press? Bin view?
2. **Bin templates:** Offer starter templates (GTD, PARA) or blank slate?
3. **Revenue model:** Subscription (covers AI costs) vs freemium (X items/month free)?
4. **Onboarding:** How many bins should user create before first use?

## Technical Stack

### Chosen Stack
- **UI:** SwiftUI (native iOS/macOS, best Apple Pencil support)
- **Sync:** CloudKit (free tier, native Apple integration, offline/sync handled)
- **AI:** OpenAI API (GPT-4o-mini for classification, ~$0.15/1M tokens)
- **Background:** BGTaskScheduler (iOS native, triggers on app close/idle)

### Architecture Overview
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   SwiftUI App   │────▶│    CloudKit     │────▶│   OpenAI API    │
│  (iOS + macOS)  │     │  (Bins, Items)  │     │ (Classification)│
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│ BGTaskScheduler │
│ (Auto-process)  │
└─────────────────┘
```

### Data Model (CloudKit)
- **Bin:** id, name, description, sortOrder, createdAt
- **Item:** id, rawText, binId (nullable), status (pending/processing/routed), createdAt, processedAt
- **Correction:** id, itemId, originalBinId, correctedBinId, timestamp (for learning)

### Key Implementation Details
1. **Processing trigger:** BGTaskScheduler on app backgrounding + ScenePhase observer
2. **Classification prompt:** System prompt with bin names/descriptions, user text as input, returns bin ID
3. **Learning:** Store corrections, include recent corrections in classification prompt as examples
4. **Offline:** Items queue locally, process when online

## Kill Criteria

- AI classification accuracy < 60% after training
- Capture friction not meaningfully lower than Apple Notes
- No path to recurring revenue after 3 months
