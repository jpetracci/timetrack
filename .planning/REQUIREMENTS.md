# Requirements: TimeTrack

**Defined:** 2026-01-30
**Core Value:** One-tap time tracking with instant project switching — start tracking immediately, switch projects without friction, see where time goes.

## v1 Requirements

### Validated

All v1 requirements have been completed and moved to the requirements archive.

### v2 Requirements

These requirements will be developed in the next milestone. Planning phase will determine final scope.

### Advanced Features

- **ADV-01**: Pomodoro timer integration
- **ADV-02**: Project templates with default tags
- **ADV-03**: Time entry notes and descriptions
- **ADV-04**: Visual charts and graphs for time analysis
- **ADV-05**: Goal tracking (daily/weekly time targets)

### Integrations

- **INTG-01**: Calendar integration for blocking time
- **INTG-02**: Basic API for third-party integrations

### User Experience Enhancements

- **UX-06**: Dark theme support
- **UX-07**: Widget support (home screen timer)
- **UX-08**: Quick project switching shortcuts
- **UX-09**: Time entry search and filtering
- **UX-10**: Batch operations (multiple time entry edit)

### Performance & Platform

- **PERF-01**: Offline mode indicator
- **PERF-02**: Data usage statistics
- **PERF-03**: Background sync preparation
- **PERF-04**: Desktop-specific optimizations

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Cloud sync / multi-device support | Privacy-focused design, local-only by requirement |
| Team features / shared projects | Single-user app, adds complexity |
| Billing / invoicing features | Time tracking focus, not a billing tool |
| Real-time collaboration | Single-user app, no network dependency |
| Advanced analytics | Simple reports sufficient for v1 |

## Context

### Current State

**Shipped:** v1.0 MVP with 28 requirements completed
**Tech Stack:** Flutter + Riverpod + SharedPreferences
**Platforms:** iOS, Android, Web
**Codebase:** ~3,000 LOC Dart, 50+ files
**Architecture:** Clean architecture with clear separation of concerns

### Constraints

- **Platform**: Flutter/Dart — maintain cross-platform approach
- **Storage**: Local first — continue privacy-focused design
- **UI**: Responsive design with platform-adaptive interactions
- **Performance**: Maintain <2s launch, handle 1000+ entries

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter + Riverpod | Proven stack, maintainability | — v1.0 shipped |
| Local-first storage | Privacy by design, no backend complexity | — v1.0 shipped |
| Decimal hours display | User preference for consistent format | — v1.0 shipped |
| Platform-adaptive UI | Different interactions per device | — v1.0 shipped |
| Semantic accessibility | Screen reader support mandatory | — v1.0 shipped |

---
*Requirements defined: 2026-01-30*
*Fresh requirements for next milestone: 2026-01-31*
*All v1 requirements completed and archived*