# Phase 3: User Interface - Context

**Gathered:** 2026-01-31
**Status:** Ready for planning

<domain>
## Phase Boundary

Polished UX with prominent timer display and intuitive controls. This phase covers visual hierarchy, display precision for decimal hours, interaction feedback, and navigation structure (Projects/Reports/Settings) without adding new features beyond the roadmap.

</domain>

<decisions>
## Implementation Decisions

### Timer prominence + layout
- Active timer lives in a sticky header band pinned above the list.
- Header shows project name + running time at minimum.
- When no timer is running, show the last project with 0.00h.
- Header includes quick start/stop control.

### Decimal time display behavior
- Default precision: 2 decimals.
- Rounding: round half-up.
- Very small durations display as 0.00h (no special thresholds).
- Always show the "h" suffix.

### Interaction feedback
- Starting a timer highlights the active project card and shows running state.
- Switching projects is instant with visual swap (old stops, new highlights).
- Feedback is visual only (no haptics).
- Action failures surface via inline snackbar.

### Navigation structure
- Use bottom tabs for navigation.
- Tabs: Projects, Reports, Settings.
- Reports are read-only in Phase 3.

### Claude's Discretion
- None explicitly granted in this phase.

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-user-interface*
*Context gathered: 2026-01-31*
