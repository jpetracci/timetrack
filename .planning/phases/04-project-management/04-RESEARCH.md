# Phase 04: Project Management - Research

**Researched:** 2026-01-30
**Domain:** Flutter (Material) + Riverpod state management + local persistence via shared_preferences
**Confidence:** MEDIUM

## Summary

This phase is about implementing full project CRUD with archival and time history management in a local-first Flutter app that already uses Riverpod Notifier controllers and shared_preferences persistence. The core work is UI + state changes: edit project name/tags, archive or delete projects (with confirmation), and manage time entries (view, edit duration, delete). Existing state patterns are NotifierProviders with immutable state objects and JSON persistence through LocalStorage.

The standard approach is to keep models immutable with copyWith/toJson, update lists in Notifier controllers, and persist via shared_preferences after every mutation. For destructive actions, use Material dialogs (showDialog + AlertDialog) with explicit confirmation. For editing or details, modal bottom sheets are a standard pattern when you want quick inline edits.

**Primary recommendation:** Extend the existing Riverpod Notifier controllers to handle update/archive/delete for Project and TimeEntry lists, persist via LocalStorage, and use Material dialogs/bottom sheets for confirmation and editing flows.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter (Material) | Flutter SDK (Dart ^3.10.8) | UI framework | Built-in widgets, dialogs, navigation, and layouts |
| flutter_riverpod | ^3.0.0 | State management | NotifierProvider pattern for mutable app state | 
| shared_preferences | ^2.3.2 | Local key-value persistence | Lightweight, cross-platform persistence for local-first data |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| uuid | ^4.5.1 | ID generation | Creating stable project/entry IDs |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| shared_preferences | SQLite/Drift | Better for large relational data, but heavier than current local-first scope |

**Installation:**
```bash
flutter pub add flutter_riverpod shared_preferences uuid
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── models/           # Project, TimeEntry value objects
├── services/         # LocalStorage (SharedPreferences persistence)
├── state/            # Riverpod Notifier controllers + immutable state
├── ui/screens/       # Screens (projects list, project details, settings)
└── widgets/          # Reusable UI components (cards, sheets)
```

### Pattern 1: Riverpod NotifierProvider for mutable state
**What:** NotifierProvider manages a state object with immutable updates and exposes mutation methods via the notifier.
**When to use:** Project list updates, archive/delete actions, time entry edits.
**Example:**
```dart
// Source: https://riverpod.dev/docs/concepts2/providers
final name = NotifierProvider<MyNotifier, Result>(MyNotifier.new);

class MyNotifier extends Notifier<Result> {
  @override
  Result build() {
    // initialize state
  }

  void updateSomething() {
    state = /* new state */;
  }
}
```

### Pattern 2: Material confirmation dialogs for destructive actions
**What:** Use showDialog with AlertDialog for explicit confirmation before delete.
**When to use:** Deleting projects, deleting time entries.
**Example:**
```dart
// Source: https://api.flutter.dev/flutter/material/AlertDialog-class.html
Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('AlertDialog Title'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
```

### Pattern 3: Modal bottom sheets for edit forms
**What:** showModalBottomSheet to present inline edit UI without full navigation.
**When to use:** Editing project name/tags or time entry duration quickly.
**Example:**
```dart
// Source: https://api.flutter.dev/flutter/material/showModalBottomSheet.html
Future<T?> showModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
})
```

### Anti-Patterns to Avoid
- **Mutating lists in-place:** Always create new lists for state updates; Notifier state should be immutable.
- **Skipping persistence after mutations:** State changes must be saved to shared_preferences to survive restart.
- **Using dialogs without context safety:** When awaiting dialog results, check `context.mounted` before acting.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Confirmation UI | Custom overlay | `showDialog` + `AlertDialog` | Built-in modal barrier, accessibility, proper focus handling |
| Temporary edit UI | Custom stack overlay | `showModalBottomSheet` | Standard modal behavior + platform animations |
| Local persistence | Ad-hoc file I/O | `shared_preferences` | Cross-platform, simple key/value persistence |

**Key insight:** The current app is already built around Riverpod + SharedPreferences, so custom persistence or overlay UI introduces unnecessary complexity.

## Common Pitfalls

### Pitfall 1: Relying on shared_preferences for critical or large data
**What goes wrong:** Writes are asynchronous and not guaranteed to be flushed immediately; large JSON payloads can become fragile.
**Why it happens:** shared_preferences is designed for simple key-value storage only.
**How to avoid:** Keep payloads small, persist after every mutation, avoid treating it as a database.
**Warning signs:** Missing updates after app restarts or data inconsistencies.

### Pitfall 2: Stale cached preferences
**What goes wrong:** Read values are stale when using the legacy cached API across isolates or multiple engine instances.
**Why it happens:** shared_preferences caches values in memory.
**How to avoid:** Use SharedPreferencesAsync/WithCache if needed or call `reload` before reads when consistency matters.
**Warning signs:** UI shows old values after background changes.

### Pitfall 3: Inconsistent time entry edits
**What goes wrong:** Editing durations can result in `end < start` or overlap with a running timer entry.
**Why it happens:** Duration edits need consistent rules for adjusting start/end.
**How to avoid:** Validate edits (end after start), disallow editing running entries or update them carefully.
**Warning signs:** Negative durations or missing entries in history.

## Code Examples

Verified patterns from official sources:

### shared_preferences read/write
```dart
// Source: https://pub.dev/packages/shared_preferences
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('action', 'Start');
final String? action = prefs.getString('action');
await prefs.remove('action');
```

### Riverpod NotifierProvider usage
```dart
// Source: https://riverpod.dev/docs/concepts2/providers
final name = NotifierProvider<MyNotifier, Result>(MyNotifier.new);

class MyNotifier extends Notifier<Result> {
  @override
  Result build() {
    // initialize state
  }
}
```

### Dialog confirmation
```dart
// Source: https://api.flutter.dev/flutter/material/showDialog.html
Future<T?> showDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
})
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `SharedPreferences` legacy API only | `SharedPreferencesAsync` / `SharedPreferencesWithCache` recommended | 2.3.0 | Better consistency and explicit cache handling |

**Deprecated/outdated:**
- `SharedPreferences` is labeled as a legacy API and expected to be deprecated in the future (use newer APIs when practical).

## Open Questions

1. **What happens to time entries when a project is deleted?**
   - What we know: Time entries are stored separately and keyed by projectId.
   - What's unclear: Whether to delete, orphan, or archive associated entries.
   - Recommendation: Decide policy before implementing delete; default to delete associated entries to keep history consistent.

2. **How should duration edits be applied?**
   - What we know: Requirement says “edit past time entries (adjust duration)” and show start/end/duration.
   - What's unclear: Whether users edit start time, end time, or duration directly.
   - Recommendation: Choose one: editing duration by adjusting `end` (keeping `start` stable) is simplest.

## Sources

### Primary (HIGH confidence)
- https://api.flutter.dev/flutter/material/showDialog.html - dialog behavior and parameters
- https://api.flutter.dev/flutter/material/AlertDialog-class.html - alert dialog usage and constraints
- https://api.flutter.dev/flutter/material/showModalBottomSheet.html - modal bottom sheet behavior
- https://pub.dev/packages/shared_preferences - persistence API, supported types, legacy vs async APIs
- https://riverpod.dev/docs/concepts2/providers - NotifierProvider pattern and state mutation guidance

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - verified via pubspec.yaml and official package docs
- Architecture: MEDIUM - Riverpod docs + existing code patterns, but no phase-specific UI spec
- Pitfalls: MEDIUM - based on shared_preferences official limitations and app-specific constraints

**Research date:** 2026-01-30
**Valid until:** 2026-03-01
