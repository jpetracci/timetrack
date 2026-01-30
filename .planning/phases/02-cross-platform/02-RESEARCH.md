# Phase 02: Cross-Platform - Research

**Researched:** 2026-01-30
**Domain:** Flutter cross-platform deployment, lifecycle-aware timer persistence
**Confidence:** MEDIUM

## Summary

This phase focuses on shipping the existing Flutter app to iOS, Android, and web while ensuring timer accuracy across backgrounding, restarts, and device reboots. The decisions lock in device clock as the source of truth, start-time-only persistence, and a basic responsive layout with a centered single-column on wide screens. The research confirms the platform lifecycle APIs to hook background/resume transitions, supported platform minimums, and the correct persistence layer for local key-value storage.

The standard approach is to persist the timer start timestamp immediately on start/stop, compute elapsed from `DateTime.now` on every foreground tick, and rehydrate from storage at launch or resume. For layout, use `SafeArea` + `MediaQuery`/`LayoutBuilder` to constrain width and adjust padding/spacing on small screens. For web, avoid trusting periodic timers in the background because browsers throttle them; always recompute elapsed from the device clock.

**Primary recommendation:** Persist only the timer start timestamp using `shared_preferences`, then derive elapsed from device clock on resume/foreground, wired through Flutter lifecycle callbacks.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK (stable) | 3.38.x (docs reference) | Cross-platform UI/runtime | Official, single codebase across iOS/Android/web |
| flutter_riverpod | ^3.0.0 | State management | Existing project decision and setup |
| shared_preferences | ^2.3.2 | Local key-value persistence | Official Flutter plugin for simple local storage |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| AppLifecycleState / WidgetsBindingObserver | Flutter SDK | App lifecycle signals | Save/restore timer state on background/resume |
| SafeArea / MediaQuery | Flutter SDK | Adaptive layout data | Responsive spacing and safe insets |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| shared_preferences | SQLite | Overkill for a single start timestamp; more complexity |

**Installation:**
```bash
flutter pub add flutter_riverpod shared_preferences
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── main.dart               # App bootstrap + lifecycle hooks
├── state/                  # Riverpod controllers/providers
├── services/               # Storage + platform services
├── ui/                     # Screens and layout
└── widgets/                # Reusable UI pieces
```

### Pattern 1: Lifecycle-Aware Timer Derivation
**What:** Persist only the timer start timestamp and compute elapsed from device clock on every foreground tick or rebuild.
**When to use:** Always for background accuracy and across restarts/reboots.
**Example:**
```dart
// Source: https://pub.dev/packages/shared_preferences
// Write
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setInt('timerStartEpochMs', DateTime.now().millisecondsSinceEpoch);

// Read
final int? startMs = prefs.getInt('timerStartEpochMs');
```

### Pattern 2: Lifecycle Hooks for Persistence
**What:** Observe lifecycle transitions (pause/inactive/hidden/resume) to trigger persistence and refresh.
**When to use:** Ensure UI immediately updates after backgrounding or resume; handle force-quit gaps.
**Example:**
```dart
// Source: https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html
// Use WidgetsBindingObserver.didChangeAppLifecycleState
```

### Pattern 3: Centered Single-Column Responsive Layout
**What:** Constrain content width to ~720px on wide screens and compress spacing on small screens.
**When to use:** Web/large devices in Phase 2 (no tablet-specific layouts yet).
**Example:**
```dart
// Source: https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery
// Use SafeArea + MediaQuery for insets/size
```

### Anti-Patterns to Avoid
- **Tick-based background timers:** Relying on `Timer.periodic` to keep time in background will drift or pause when the OS throttles execution.
- **Persisting only in dispose:** Lifecycle events can be skipped (force-quit), so write start time immediately on start/stop and on background transitions.
- **Ignoring SafeArea:** UI can be clipped by notches or system UI.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Local persistence | Custom file format | `shared_preferences` | Official plugin, cross-platform storage (NSUserDefaults/SharedPreferences/localStorage) |
| Background timing | OS background service for ticking | Device clock diff | Meets accuracy requirement without platform-specific services |
| Platform branching | Ad-hoc platform code | Flutter lifecycle APIs | Cross-platform lifecycle consistency |

**Key insight:** This phase does not require background execution; it requires correct elapsed time derived from wall clock on resume/foreground.

## Common Pitfalls

### Pitfall 1: Assuming lifecycle callbacks always fire
**What goes wrong:** App is killed without a final lifecycle callback; timer state is lost.
**Why it happens:** OS or user kills app abruptly; Flutter warns states may be skipped.
**How to avoid:** Persist start time on every start/stop action and on each transition to background.
**Warning signs:** Timer resets to zero after a force-quit.

### Pitfall 2: Relying on periodic timers in background/web
**What goes wrong:** Timer freezes or drifts when app is backgrounded or browser tab is inactive.
**Why it happens:** OS and browsers throttle background execution.
**How to avoid:** Compute elapsed from `DateTime.now()` on resume/foreground and UI rebuild.
**Warning signs:** Large time jumps or time not advancing while backgrounded.

### Pitfall 3: Not awaiting shared_preferences writes
**What goes wrong:** Start timestamp isn't persisted, leading to lost state on restart.
**Why it happens:** Writes are async; persistence isn't guaranteed immediately after call.
**How to avoid:** `await` writes and avoid using it for critical transactional data.
**Warning signs:** Intermittent loss of active timer after app restarts.

### Pitfall 4: Hard-coded layout spacing on small screens
**What goes wrong:** Content overflows or becomes cramped on smaller devices.
**Why it happens:** Fixed padding ignores device size and safe insets.
**How to avoid:** Use `MediaQuery` + `SafeArea` and scale padding by width.
**Warning signs:** Overflow warnings or clipped UI in simulator rotation.

## Code Examples

Verified patterns from official sources:

### Persisting a start timestamp
```dart
// Source: https://pub.dev/packages/shared_preferences
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setInt('timerStartEpochMs', DateTime.now().millisecondsSinceEpoch);

final int? startMs = prefs.getInt('timerStartEpochMs');
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Legacy `SharedPreferences` API only | `SharedPreferencesAsync` / `SharedPreferencesWithCache` recommended | shared_preferences 2.3.0 | Avoids stale cache issues and improves correctness across isolates |

**Deprecated/outdated:**
- `SharedPreferences` legacy API: still supported but recommended to migrate to async or cache variants.

## Open Questions

1. **Which shared_preferences API to standardize on (Async vs WithCache)?**
   - What we know: 2.3+ recommends Async/WithCache for correctness; legacy API can have cache issues.
   - What's unclear: whether Phase 1 code already uses legacy API and how much refactor is acceptable now.
   - Recommendation: Use `SharedPreferencesAsync` for new timer start-time persistence to avoid cache issues.

## Sources

### Primary (HIGH confidence)
- https://docs.flutter.dev/reference/supported-platforms - Supported platform versions (Android 24+, iOS 13+, web browser support)
- https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html - Lifecycle states and guarantees
- https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html - Observing app lifecycle changes
- https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery - SafeArea and MediaQuery usage

### Secondary (MEDIUM confidence)
- https://pub.dev/packages/shared_preferences - Storage behavior, supported platforms, new APIs
- https://docs.flutter.dev/deployment/web - Web build/deploy basics (debug vs release)

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - project versions and official docs
- Architecture: MEDIUM - lifecycle pattern and responsive guidance from official docs, but app-specific decisions required
- Pitfalls: MEDIUM - grounded in lifecycle docs and shared_preferences behavior

**Research date:** 2026-01-30
**Valid until:** 2026-02-29
