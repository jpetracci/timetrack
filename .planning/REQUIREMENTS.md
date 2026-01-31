# Requirements: TimeTrack

**Defined:** 2026-01-30
**Core Value:** One-tap time tracking with instant project switching — start tracking immediately, switch projects without friction, see where time goes.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Core Timer Functionality

 - [x] **TIMER-01**: User can start timer with single tap on any project
 - [x] **TIMER-02**: User can stop timer with single tap 
 - [x] **TIMER-03**: Starting timer on new project auto-stops current timer
- [x] **TIMER-04**: Timer continues running accurately when app is in background
- [x] **TIMER-05**: Timer persists across app restarts without data loss

### Project Management

 - [x] **PROJ-01**: User can create new project with name
 - [x] **PROJ-02**: User can add tags to projects for organization
- [x] **PROJ-03**: User can edit project name and tags
- [x] **PROJ-04**: User can delete individual projects
- [x] **PROJ-05**: User can archive projects (hide from main view)
- [ ] **PROJ-06**: Active project displayed prominently at top of screen

### Time Display & History

- [ ] **DISP-01**: Time displayed in decimal hours (default 2 decimal places)
- [ ] **DISP-02**: User can configure decimal precision (1-4 places)
- [x] **DISP-03**: User can view project details with complete time history
- [x] **DISP-04**: User can edit past time entries (adjust duration)
- [x] **DISP-05**: User can delete individual time entries
- [x] **DISP-06**: Time history shows start/end times and duration

### Reporting

 - [x] **REPT-01**: User can view daily time report (simple table format)
 - [x] **REPT-02**: User can view weekly time report (simple table format)
 - [x] **REPT-03**: Reports show project totals and daily breakdowns
 - [x] **REPT-04**: Reports can be filtered by date range

### Data Storage

 - [x] **STOR-01**: All data stored locally on device (no network dependency)
 - [x] **STOR-02**: Data persists across app updates
 - [x] **STOR-03**: User can export data as JSON/CSV
 - [x] **STOR-04**: Data migration handled when app schema changes

### Platform Support

- [x] **PLAT-01**: App runs on iOS devices with responsive design
- [x] **PLAT-02**: App runs on Android devices with responsive design  
- [x] **PLAT-03**: App runs on web browsers with responsive design
- [ ] **PLAT-04**: Touch interface optimized for mobile devices
- [ ] **PLAT-05**: Pointer interface optimized for web/desktop use

### User Experience

- [ ] **UX-01**: App launches and is ready to use within 2 seconds
- [ ] **UX-02**: Timer controls remain accessible during scrolling/navigation
- [ ] **UX-03**: Visual feedback for all user interactions
- [ ] **UX-04**: Clear visual distinction between active and inactive projects
- [ ] **UX-05**: Intuitive navigation between project list, reports, and settings

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Advanced Features

- **ADV-01**: Pomodoro timer integration
- **ADV-02**: Project templates with default tags
- **ADV-03**: Time entry notes and descriptions
- **ADV-04**: Visual charts and graphs for time analysis
- **ADV-05**: Goal tracking (daily/weekly time targets)

### Integrations

- **INTG-01**: Calendar integration for blocking time
- **INTG-02**: Basic API for third-party integrations

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Cloud sync / multi-device support | Privacy-focused design, local-only by requirement |
| Team features / shared projects | Single-user app, adds complexity |
| Billing / invoicing features | Time tracking focus, not accounting |
| Real-time collaboration | Single-user app, no network dependency |
| Push notifications | User preference, no background alerts needed |
| Complex analytics | Simple reports sufficient for v1 |
| Subscription/Premium features | One-time purchase model preferred |
| Data import from other time trackers | Export prioritized over import for simplicity |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| TIMER-01 | Phase 1 | Complete |
| TIMER-02 | Phase 1 | Complete |
| TIMER-03 | Phase 1 | Complete |
| PROJ-01 | Phase 1 | Complete |
| PROJ-02 | Phase 1 | Complete |
| STOR-01 | Phase 1 | Complete |
| PLAT-01 | Phase 2 | Complete |
| PLAT-02 | Phase 2 | Complete |
| PLAT-03 | Phase 2 | Complete |
| TIMER-04 | Phase 2 | Complete |
| TIMER-05 | Phase 2 | Complete |
| PROJ-06 | Phase 3 | Pending |
| DISP-01 | Phase 3 | Pending |
| DISP-02 | Phase 3 | Pending |
| UX-01 | Phase 3 | Pending |
| UX-02 | Phase 3 | Pending |
| UX-03 | Phase 3 | Pending |
| UX-04 | Phase 3 | Pending |
| UX-05 | Phase 3 | Pending |
| PROJ-03 | Phase 4 | Complete |
| PROJ-04 | Phase 4 | Complete |
| PROJ-05 | Phase 4 | Complete |
| DISP-03 | Phase 4 | Complete |
| DISP-04 | Phase 4 | Complete |
| DISP-05 | Phase 4 | Complete |
| DISP-06 | Phase 4 | Complete |
| REPT-01 | Phase 5 | Complete |
| REPT-02 | Phase 5 | Complete |
| REPT-03 | Phase 5 | Complete |
| REPT-04 | Phase 5 | Complete |
| STOR-02 | Phase 5 | Complete |
| STOR-03 | Phase 5 | Complete |
| STOR-04 | Phase 5 | Complete |
| PLAT-04 | Phase 6 | Pending |
| PLAT-05 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 28 total
- Mapped to phases: 28
- Unmapped: 0 ✓

---
*Requirements defined: 2026-01-30*
*Last updated: 2026-01-31 after Phase 2 verification*
