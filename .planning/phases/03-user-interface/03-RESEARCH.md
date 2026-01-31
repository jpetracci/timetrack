# Phase 03: User Interface - Research

**Researched:** 2026-01-30
**Domain:** Flutter UI (Material) + Riverpod UI state + display formatting
**Confidence:** MEDIUM

## Summary

This phase focuses on Flutter UI composition for a prominent, sticky timer header, bottom-tab navigation, and clear active/inactive project feedback while keeping the app fast to launch. The standard implementation uses a single top-level `Scaffold`, bottom navigation for top-level views, and a pinned sliver header (`SliverPersistentHeader` or `SliverAppBar`) above the project list so the timer controls remain visible while scrolling.

State and UI wiring should follow Riverpod consumer patterns to keep rebuilds small, with `select` used to watch only the fields needed for the header and each list card. Decimal hour display should use a deterministic rounding step (half-up for positive durations) before formatting via `toStringAsFixed`, and user precision should live in SharedPreferences-backed settings.

**Primary recommendation:** Use a single `Scaffold` with bottom tabs and a pinned sliver header, driven by Riverpod consumers with `select` to minimize rebuilds, and format decimal hours via `round` + `toStringAsFixed`.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter (Material) | latest stable | UI layout, navigation, widgets | Official UI framework for the project |
| flutter_riverpod | ^3.2.0 | UI state + reactive updates | Riverpod standard for provider-driven UI and Consumer widgets |
| shared_preferences | ^2.5.4 | Persist UI settings (decimal precision) | Official Flutter plugin for small key-value settings |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Dart core (`num.round`, `toStringAsFixed`) | Dart 3.10.x | Deterministic rounding + formatting | Decimal hour display formatting |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `BottomNavigationBar` | `NavigationBar` (Material 3) | Preferred for Material 3, but requires M3 theming alignment |
| `SliverPersistentHeader` | `SliverAppBar(pinned: true)` | App bar behaviors vs custom header layout control |

**Installation:**
```bash
flutter pub add flutter_riverpod shared_preferences
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── ui/
│   ├── screens/        # Projects, Reports (read-only), Settings
│   ├── widgets/        # Header, project card, timer controls
│   └── theme/          # Typography, color tokens
├── state/              # Riverpod providers/notifiers
└── services/           # SharedPreferences settings adapter
```

### Pattern 1: Single Scaffold + Bottom Tabs
**What:** One top-level `Scaffold` with a bottom navigation bar and page body swapped by index.
**When to use:** Required for UX-05 (clear navigation) and to avoid nested scaffolds.
**Example:**
```dart
// Source: https://api.flutter.dev/flutter/material/Scaffold-class.html
Scaffold(
  body: pages[currentIndex],
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTabSelected,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Projects'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ],
  ),
);
```

### Pattern 2: Sticky Timer Header Above List
**What:** A pinned sliver header so the timer remains visible while scrolling projects.
**When to use:** UX-02 (timer controls remain accessible during scrolling).
**Example:**
```dart
// Source: https://api.flutter.dev/flutter/widgets/SliverPersistentHeader-class.html
CustomScrollView(
  slivers: [
    SliverPersistentHeader(
      pinned: true,
      delegate: TimerHeaderDelegate(...),
    ),
    SliverList(delegate: SliverChildBuilderDelegate(buildProjectCard)),
  ],
);
```

### Pattern 3: Riverpod ConsumerWidget + select
**What:** Use `ConsumerWidget` and `ref.watch(...select(...))` to rebuild only what is needed.
**When to use:** Frequent timer ticks and list updates; keep UI fast for UX-01.
**Example:**
```dart
// Source: https://riverpod.dev/docs/concepts2/consumers
class TimerHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeName = ref.watch(activeProjectProvider.select((p) => p.name));
    final hours = ref.watch(timerProvider.select((t) => t.decimalHours));
    return Text('$activeName $hours');
  }
}
```

### Anti-Patterns to Avoid
- **Nested Scaffolds:** Causes inconsistent app bars and bottom bars; use a single top-level scaffold.
- **Watching entire models for the list:** Rebuilds all cards on any change; use `select` to watch only fields each card needs.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Sticky header | Custom scroll math | `SliverPersistentHeader` / `SliverAppBar(pinned: true)` | Built-in pinned behavior and layout handling |
| In-app errors | Custom overlay | `ScaffoldMessenger.showSnackBar` + `SnackBar` | Standard UX and animation behavior |
| Preferences storage | Custom file/JSON | `shared_preferences` | Cross-platform persistence for simple settings |

**Key insight:** Flutter already provides sliver pinning, snackbars, and preference storage; custom implementations add edge cases without UX benefit.

## Common Pitfalls

### Pitfall 1: Non-deterministic rounding for decimal hours
**What goes wrong:** Displayed hours differ from half-up expectation (e.g., 1.005 -> 1.00).
**Why it happens:** Formatting without an explicit rounding step.
**How to avoid:** Round with `num.round()` on the scaled value before `toStringAsFixed`.
**Warning signs:** Inconsistent UI values at .005 boundaries.

### Pitfall 2: Excessive rebuilds on timer ticks
**What goes wrong:** Janky scrolling or slow UI updates.
**Why it happens:** Watching full provider objects in many widgets.
**How to avoid:** Use `select` to watch only needed fields; isolate header/card widgets.
**Warning signs:** Rebuild logs show entire list updating each tick.

### Pitfall 3: SharedPreferences cache drift
**What goes wrong:** Settings changes don’t appear immediately in UI.
**Why it happens:** Using cached legacy API across isolates or missing reloads.
**How to avoid:** Prefer `SharedPreferencesAsync` or explicitly `reload` before reading.
**Warning signs:** Settings screen updates but display stays stale.

### Pitfall 4: Nested scaffolds in tab views
**What goes wrong:** Duplicate app bars/bottom nav or layout glitches.
**Why it happens:** Creating a Scaffold per tab screen.
**How to avoid:** One root `Scaffold` and switch body content.
**Warning signs:** Multiple nav bars visible or overlapping paddings.

## Code Examples

Verified patterns from official sources:

### Pinned Header with Slivers
```dart
// Source: https://api.flutter.dev/flutter/widgets/SliverPersistentHeader-class.html
SliverPersistentHeader(
  pinned: true,
  delegate: TimerHeaderDelegate(...),
)
```

### Bottom Tabs
```dart
// Source: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
BottomNavigationBar(
  currentIndex: currentIndex,
  onTap: onTabSelected,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Projects'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
)
```

### Snackbar for Inline Errors
```dart
// Source: https://api.flutter.dev/flutter/material/SnackBar-class.html
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Could not start timer')),
);
```

### Round Half-Up + Fixed Decimals
```dart
// Source: https://api.dart.dev/stable/dart-core/num/round.html
// Source: https://api.dart.dev/stable/dart-core/num/toStringAsFixed.html
String formatHours(double hours, int decimals) {
  final factor = math.pow(10, decimals).toDouble();
  final rounded = (hours * factor).round() / factor;
  return '${rounded.toStringAsFixed(decimals)}h';
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `BottomNavigationBar` | `NavigationBar` (Material 3) | Flutter Material 3 adoption | New visuals, different API surface |
| Legacy `SharedPreferences` API | `SharedPreferencesAsync` / `SharedPreferencesWithCache` | shared_preferences 2.3.0+ | Avoids stale cache issues; async reads |

**Deprecated/outdated:**
- **Legacy `SharedPreferences` API:** New APIs recommended for new usage; legacy is slated for deprecation in the package docs.

## Open Questions

1. **Material 3 adoption for bottom tabs**
   - What we know: Flutter docs prefer `NavigationBar` for Material 3.
   - What's unclear: Whether the app is using `ThemeData.useMaterial3`.
   - Recommendation: If Material 3 is enabled, use `NavigationBar`; otherwise `BottomNavigationBar`.

## Sources

### Primary (HIGH confidence)
- https://api.flutter.dev/flutter/material/Scaffold-class.html - Scaffold structure and guidance on avoiding nested scaffolds
- https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html - Bottom tabs API and M3 `NavigationBar` note
- https://api.flutter.dev/flutter/widgets/SliverPersistentHeader-class.html - Pinned header support
- https://api.flutter.dev/flutter/material/SnackBar-class.html - SnackBar usage with ScaffoldMessenger
- https://api.dart.dev/stable/dart-core/num/round.html - Half-up rounding behavior
- https://api.dart.dev/stable/dart-core/num/toStringAsFixed.html - Fixed decimal formatting rules

### Secondary (MEDIUM confidence)
- https://riverpod.dev/docs/concepts2/consumers - ConsumerWidget patterns
- https://riverpod.dev/docs/how_to/select - Using `select` to reduce rebuilds
- https://pub.dev/packages/shared_preferences - SharedPreferences APIs and new async/cache options

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official Flutter and package docs
- Architecture: HIGH - Flutter sliver and scaffold docs
- Pitfalls: MEDIUM - Based on official guidance + practical UI constraints

**Research date:** 2026-01-30
**Valid until:** 2026-02-29
