# TimeTrack

## What This Is

A Flutter time-tracking app that runs on mobile (iOS/Android) and web. Users create projects, tap to start a timer, and track how long they spend on each. Time is displayed in decimal hours, reports summarize daily/weekly totals, and all data stays local on the device.

## Core Value

One-tap time tracking with instant project switching — start tracking immediately, switch projects without friction, see where time goes.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Create and manage projects (name + tags)
- [ ] One-tap start/stop timer on any project
- [ ] Switching projects auto-stops the current timer
- [ ] Active project displayed prominently at top of screen
- [ ] Time displayed in configurable decimal hours (default 2 decimal places)
- [ ] View project details and time history
- [ ] Edit and delete past time entries
- [ ] Archive and delete projects
- [ ] Daily and weekly time reports (simple table)
- [ ] All data stored locally on device
- [ ] Runs on iOS, Android, and web

### Out of Scope

- Cloud sync / remote storage — local-only by design
- Team features / shared projects — single-user app
- Billing / invoicing — this is a time tracker, not a billing tool
- Notifications / reminders — no background alerts
- Pause/resume within a single session — stop creates a new entry

## Context

- Flutter framework targets all three platforms (iOS, Android, web) from a single codebase
- Local storage needs to handle time entries that can accumulate over months/years
- Timer must keep running accurately even when app is in background on mobile
- Decimal time display (e.g., 2.75h instead of 2h 45m) is the primary format everywhere
- Tags on projects are simple labels (not structured key-value fields)

## Constraints

- **Platform**: Flutter/Dart — cross-platform requirement drives this choice
- **Storage**: Local only — no backend, no accounts, no network dependency
- **UI**: Must work well on both touch (mobile) and pointer (web) inputs

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Decimal hours everywhere | User preference for consistent decimal display | — Pending |
| Tags over custom fields | Simpler data model, covers the use case | — Pending |
| Stop-only (no pause) | Simpler interaction model, starting again creates new entry | — Pending |
| Local storage only | Privacy, simplicity, no backend maintenance | — Pending |

---
*Last updated: 2026-01-30 after initialization*
