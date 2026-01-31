# TimeTrack

## What This Is

A Flutter time-tracking app that runs on mobile (iOS/Android) and web. Users create projects, tap to start a timer, and track how long they spend on each. Time is displayed in decimal hours, reports summarize daily/weekly totals, and all data stays local on device.

## Core Value

One-tap time tracking with instant project switching — start tracking immediately, switch projects without friction, see where time goes.

## Current State

**Shipped:** v1.0 MVP (2026-01-31)
- Cross-platform time-tracking with 28 requirements completed
- iOS, Android, and web deployment ready
- Local-first data storage with comprehensive reporting

**Next Milestone Goals:**
- Advanced features (Pomodoro, templates, notes)
- Performance optimizations and desktop enhancements
- User experience improvements (dark theme, widgets)

### Validated

All v1 requirements have been shipped. See [.planning/milestones/v1-REQUIREMENTS.md](.planning/milestones/v1-REQUIREMENTS.md) for complete record.

### Active

- [ ] Pomodoro timer integration
- [ ] Project templates with default tags
- [ ] Time entry notes and descriptions
- [ ] Visual charts and graphs for time analysis
- [ ] Goal tracking (daily/weekly time targets)
- [ ] Calendar integration for blocking time
- [ ] Dark theme support
- [ ] Widget support (home screen timer)
- [ ] Quick project switching shortcuts
- [ ] Time entry search and filtering
- [ ] Batch operations (multiple time entry edit)

### Out of Scope

- Cloud sync / multi-device support — Privacy-focused design, local-only by requirement
- Team features / shared projects — Single-user app, adds complexity
- Billing / invoicing features — Time tracking focus, not a billing tool
- Notifications / reminders — v1 focused on core functionality
- Advanced analytics — Simple reports sufficient for current needs

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

*Last updated: 2026-01-31 after v1.0 milestone completion*
