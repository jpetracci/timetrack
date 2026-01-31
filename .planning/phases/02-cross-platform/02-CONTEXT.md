# Phase 2: Cross-Platform - Context

**Gathered:** 2026-01-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Deploy to iOS, Android, and web with background timer support. Ensure timer continues accurately when app is backgrounded and layout adapts across screen sizes. No new feature scope beyond cross-platform support.

</domain>

<decisions>
## Implementation Decisions

### Background timer behavior
- Timer keeps running automatically when the app is backgrounded.
- Use device clock as the source of truth (elapsed = now minus saved start time), not a continuous tick while backgrounded.
- Timer continues through device sleep/lock.
- On web, timer continues even when the tab is in the background.

### Platform build targets
- Target Flutter default stable minimum OS versions for iOS and Android.
- Web support is required in Phase 2 (ship iOS, Android, and web together).
- Tablet support is basic responsive scaling only (no tablet-specific layout in Phase 2).
- Distribution scope is debug/run only (no store release signing in Phase 2).

### Lifecycle + restore expectations
- Persist only the start time; compute elapsed as current time minus start time on resume.
- If the app is force-quit while timing, resume automatically on next launch.
- Device clock is the source of truth if time changes while running.
- On resume, UI should immediately show updated elapsed time.

### Responsive layout baseline
- Use a single-column layout on wide screens with centered content.
- Max content width on wide screens is ~720px.
- Active timer area stays visible while scrolling the project list.
- On very small screens, compress spacing rather than keeping fixed padding.

### Claude's Discretion
- None explicitly granted in this phase.

</decisions>

<specifics>
## Specific Ideas

- Use device clock for elapsed time (diff between saved start time and now).

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-cross-platform*
*Context gathered: 2026-01-30*
