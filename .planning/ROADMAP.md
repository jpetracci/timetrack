# Roadmap: TimeTrack

## Overview

Building a cross-platform time-tracking app from scratch using Flutter, starting with core timer functionality and progressively adding project management, reporting, and platform optimization. The journey begins with a minimal viable timer and expands to a full-featured time tracking solution while maintaining simplicity and local-first privacy.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation** - Core timer and project creation
- [x] **Phase 2: Cross-Platform** - iOS, Android, and web deployment
- [ ] **Phase 3: User Interface** - Polished UX and timer display
- [x] **Phase 4: Project Management** - Full project CRUD operations
- [ ] **Phase 5: Reporting** - Daily/weekly reports and data export
- [ ] **Phase 6: Platform Polish** - Touch/pointer optimization and performance

## Phase Details

### Phase 1: Foundation
**Goal**: Basic timer functionality with simple project management
**Depends on**: Nothing (first phase)
**Requirements**: TIMER-01, TIMER-02, TIMER-03, PROJ-01, PROJ-02, STOR-01
**Success Criteria** (what must be TRUE):
  1. User can create a project and start timing it with one tap
  2. User can switch between projects and timer auto-stops current one
  3. All data persists locally when app is closed and reopened
  4. Timer shows running time in decimal hours while active
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md — Flutter scaffold + models + SharedPreferences storage
- [x] 01-02-PLAN.md — Timer logic + auto-stop switching + persistence restore
- [x] 01-03-PLAN.md — Core UI with project list, add project, and timer controls

### Phase 2: Cross-Platform
**Goal**: Deploy to iOS, Android, and web with background timer support
**Depends on**: Phase 1
**Requirements**: PLAT-01, PLAT-02, PLAT-03, TIMER-04, TIMER-05
**Success Criteria** (what must be TRUE):
  1. App installs and runs on iOS, Android, and web browsers
  2. Timer continues running accurately when app goes to background
  3. Timer state persists across app restarts and device reboots
  4. Layout adapts properly to different screen sizes and orientations
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md — Align platform metadata and minimum OS targets
- [x] 02-02-PLAN.md — Add lifecycle-aware background timer handling
- [x] 02-03-PLAN.md — Establish responsive layout foundation

### Phase 3: User Interface
**Goal**: Polished UX with prominent timer display and intuitive controls
**Depends on**: Phase 2
**Requirements**: PROJ-06, DISP-01, DISP-02, UX-01, UX-02, UX-03, UX-04, UX-05
**Success Criteria** (what must be TRUE):
  1. Active project and timer displayed prominently at top of screen
  2. Time shows in configurable decimal hours (1-4 decimal places)
  3. App launches and is usable within 2 seconds
  4. Clear visual distinction between active and inactive projects
**Plans**: 3 plans

Plans:
- [x] 03-01-PLAN.md — Main shell with tabs + sticky timer header
- [x] 03-02-PLAN.md — Decimal time formatting + precision settings
- [x] 03-03-PLAN.md — Interaction feedback + UI transitions

### Phase 4: Project Management
**Goal**: Complete project CRUD with archival and time history
**Depends on**: Phase 3
**Requirements**: PROJ-03, PROJ-04, PROJ-05, DISP-03, DISP-04, DISP-05, DISP-06
**Success Criteria** (what must be TRUE):
  1. User can edit project names and tags from project details screen
  2. User can delete projects with confirmation dialog
  3. User can archive projects to hide them from main list
  4. Project details show complete time history with editable entries
**Plans**: 3 plans

Plans:
- [x] 04-01-PLAN.md — Project details with edit + delete flows
- [x] 04-02-PLAN.md — Project archival + archive management screen
- [x] 04-03-PLAN.md — Time history UI with inline edit/delete

### Phase 5: Reporting
**Goal**: Daily/weekly reports with data export and persistence
**Depends on:** Phase 4
**Requirements**: REPT-01, REPT-02, REPT-03, REPT-04, STOR-02, STOR-03, STOR-04
**Success Criteria** (what must be TRUE):
  1. User can view daily report showing time spent per project
  2. User can view weekly report with project totals and daily breakdown
  3. User can export all data as JSON or CSV file
  4. Data migration works smoothly when app schema changes
**Plans**: 3 plans

Plans:
- [ ] 05-01-PLAN.md — Report aggregation helpers with tests
- [ ] 05-02-PLAN.md — Reports screen with daily/weekly tables and date range filtering
- [ ] 05-03-PLAN.md — Data export (JSON/CSV) and schema migration framework

### Phase 6: Platform Polish
**Goal**: Optimize touch/pointer interfaces and app performance
**Depends on**: Phase 5
**Requirements**: PLAT-04, PLAT-05
**Success Criteria** (what must be TRUE):
  1. Touch interface feels natural on mobile with proper tap targets
  2. Pointer interface works smoothly on web with hover states
  3. App performs well with large datasets (1000+ time entries)
  4. All platform accessibility guidelines are met
**Plans**: 2 plans

Plans:
- [ ] 06-01: Optimize touch interactions for mobile and hover states for web
- [ ] 06-02: Performance tuning and accessibility compliance

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 3/3 | Complete | 2026-01-30 |
| 2. Cross-Platform | 3/3 | Complete | 2026-01-30 |
| 3. User Interface | 3/3 | Complete | 2026-01-31 |
| 4. Project Management | 3/3 | Complete | 2026-01-31 |
| 5. Reporting | 0/3 | Not started | - |
| 6. Platform Polish | 0/2 | Not started | - |

---
*Roadmap created: 2026-01-30*
*Last updated: 2026-01-31 after Phase 4 verification*
