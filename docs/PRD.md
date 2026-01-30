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
- All captures land in single chronological inbox
- No organization required at capture time
- Items persist until processed

### 3. Batch Processing
- User-triggered "Process" action (not real-time)
- AI classifies each item based on user's defined categories
- Presents classification for review before routing

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

- Real-time classification (batch only)
- External integrations (Obsidian, Notion, etc.) - v2
- Voice capture - v2
- Image/file capture - v2
- Collaborative features
- Android
- Web app

## Success Criteria

1. Capture-to-close time < 5 seconds
2. AI classification accuracy > 80% after 50 corrections
3. User processes inbox at least weekly (engagement metric)
4. Items don't pile up indefinitely (routing actually happens)

## Open Questions

1. **AI backend:** OpenAI API, local model, or Apple on-device intelligence?
2. **Sync architecture:** iCloud, custom backend, or local-only?
3. **Correction UX:** How does user override and teach the system?
4. **Bin templates:** Offer starter templates (GTD, PARA) or blank slate?
5. **Revenue model:** Subscription (for AI costs) vs one-time vs freemium?

## Technical Considerations

### Likely Stack
- **UI:** SwiftUI (native iOS/macOS)
- **Sync:** CloudKit (Apple ecosystem, free tier)
- **AI:** TBD - options include OpenAI API, Apple on-device, or hybrid

### Key Technical Decisions Needed
1. Where does AI inference run? (Cloud vs device)
2. How are bins and rules stored?
3. What's the correction/learning mechanism?

## Kill Criteria

- AI classification accuracy < 60% after training
- Capture friction not meaningfully lower than Apple Notes
- No path to recurring revenue after 3 months
