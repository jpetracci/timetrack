# Phase 05: Reporting - Research

**Researched:** 2026-01-30
**Domain:** Flutter reporting, export, and local persistence
**Confidence:** MEDIUM

## Summary

This phase centers on building daily/weekly reporting over existing time entry history, plus robust data export and schema migration on top of the current Flutter + Riverpod + SharedPreferences stack. The standard approach is to compute report aggregates as derived state (Riverpod providers) from persisted entries/projects, and to export JSON/CSV using Dart’s built-in JSON tooling plus a CSV encoder, writing files to app directories and sharing them through the platform share sheet.

SharedPreferences is still appropriate for local-first persistence, but it now offers newer Async/WithCache APIs (recommended for new code). For migration, the common pattern is to store a schema version key, run sequential migrations at load time, and keep JSON parsing resilient to missing fields. Reporting logic should normalize date boundaries and handle entries spanning day/week boundaries.

**Primary recommendation:** Implement report aggregation as pure functions exposed via Riverpod providers, and export files using `dart:convert` + `csv` with `path_provider` + `share_plus` for user delivery.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | stable | UI + platform integration | Official framework for the app |
| flutter_riverpod | ^3.2.0 | State management, derived providers | Standard Riverpod package for Flutter apps |
| shared_preferences | ^2.5.4 | Local persistence | Flutter-favorite key-value persistence plugin |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| csv | ^6.0.0 | CSV encoding/decoding | Generate CSV exports from report rows |
| path_provider | ^2.1.5 | File system directories | Write export files to app document/temp directories |
| share_plus | ^12.0.1 | Share files via OS UI | Deliver exported JSON/CSV to user |
| dart:convert | SDK | JSON encoding/decoding | Build JSON export payloads |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| share_plus | file_selector / file_saver | File pickers give explicit save location but add platform-specific UX work |

**Installation:**
```bash
flutter pub add csv path_provider share_plus
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── models/                 # Core data models (Project, TimeEntry, ReportRow)
├── services/               # IO + persistence (LocalStorage, ReportExportService)
├── state/                  # Riverpod notifiers/providers (ReportController)
├── ui/screens/             # Reporting screens
└── ui/widgets/             # Report UI widgets (tables, totals, filters)
```

### Pattern 1: Derived report providers
**What:** Compute daily/weekly aggregates as pure functions; expose via Riverpod providers that watch entries/projects + date range filter.
**When to use:** All report UIs; keeps UI simple and ensures reports update when data changes.
**Example:**
```dart
// Source: https://riverpod.dev/docs/introduction/getting_started
@riverpod
List<ProjectTotals> dailyReport(Ref ref, DateTime day) {
  final entries = ref.watch(entriesProvider);
  final projects = ref.watch(projectsProvider);
  return buildDailyTotals(entries, projects, day);
}
```

### Pattern 2: Versioned persistence + migration on load
**What:** Store a schema version in SharedPreferences and run migrations on app start before loading data into providers.
**When to use:** Any schema change (new fields, renamed keys, different storage layout).
**Example:**
```dart
// Source: https://pub.dev/packages/shared_preferences
final SharedPreferences prefs = await SharedPreferences.getInstance();
final int schemaVersion = prefs.getInt('schema_version') ?? 1;
// if schemaVersion < 2: migrate and then set new version
await prefs.setInt('schema_version', 2);
```

### Anti-Patterns to Avoid
- **Compute reports in widget build methods:** Expensive and hard to test; use providers/services instead.
- **Ignore entries spanning day boundaries:** Causes incorrect daily totals; split durations at midnight.
- **Skip schema versioning:** Makes migrations error-prone when fields change.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| CSV encoding | Manual string concatenation | `csv` package | Handles RFC4180 quoting/escaping reliably |
| JSON encoding | Custom serializers | `dart:convert` json codec | Standard, tested encoder/decoder |
| File locations | Hardcoded paths | `path_provider` | Correct per-platform storage paths |
| Share UI | Platform-specific intents | `share_plus` | Cross-platform share sheet support |

**Key insight:** Export and persistence have platform edge cases; using standard packages avoids data loss and platform bugs.

## Common Pitfalls

### Pitfall 1: Entries that span midnight
**What goes wrong:** Daily totals over/under-count because an entry is attributed entirely to one day.
**Why it happens:** Entries are stored as start/end timestamps without daily splitting.
**How to avoid:** When building daily reports, split any entry that crosses day boundaries into per-day slices.
**Warning signs:** Totals exceed 24h or are inconsistent with entry list.

### Pitfall 2: Week boundaries vary by locale
**What goes wrong:** Weekly reports disagree with user expectations.
**Why it happens:** Week start (Monday vs Sunday) is hard-coded.
**How to avoid:** Define a consistent week-start policy and apply it in date-range calculations.
**Warning signs:** Week totals shift when user changes locale or on boundary days.

### Pitfall 3: SharedPreferences cache staleness
**What goes wrong:** Reads return stale data in multi-isolate or multi-engine scenarios.
**Why it happens:** SharedPreferences uses a local cache; updates in other contexts aren’t visible.
**How to avoid:** Prefer `SharedPreferencesAsync` or call `reload()` before reads when needed.
**Warning signs:** Data mismatches after background work or plugin writes.

### Pitfall 4: Exported files not accessible to users
**What goes wrong:** Files are written to app directories but users can’t retrieve them.
**Why it happens:** App sandbox paths are not user-visible on mobile.
**How to avoid:** Share the generated files through the OS share sheet.
**Warning signs:** “Export complete” but users can’t find the file.

## Code Examples

Verified patterns from official sources:

### JSON encode/decode
```dart
// Source: https://api.dart.dev/stable/3.10.8/dart-convert/
import 'dart:convert';

final encoded = json.encode([1, 2, {'a': null}]);
final decoded = json.decode('["foo", {"bar": 499}]');
```

### CSV encoding
```dart
// Source: https://pub.dev/packages/csv
import 'package:csv/csv.dart';

final csv = const ListToCsvConverter().convert([
  ['Project', 'Hours'],
  ['Client A', 3.5],
]);
```

### Get app documents directory
```dart
// Source: https://pub.dev/packages/path_provider
import 'package:path_provider/path_provider.dart';

final dir = await getApplicationDocumentsDirectory();
```

### Share exported files
```dart
// Source: https://pub.dev/packages/share_plus
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

final params = ShareParams(files: [XFile('/path/to/report.csv')]);
await SharePlus.instance.share(params);
```

### SharedPreferences read/write
```dart
// Source: https://pub.dev/packages/shared_preferences
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('export_last_run', '2026-01-30');
final String? value = prefs.getString('export_last_run');
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| SharedPreferences legacy API | SharedPreferencesAsync / WithCache | shared_preferences 2.3.0 | Prefer async/no-cache for fresh reads and multi-isolate safety |

**Deprecated/outdated:**
- SharedPreferences legacy API: discouraged for new code; newer APIs are recommended by the plugin docs.

## Open Questions

1. **Export UX (share vs save-to-location)**
   - What we know: Export must produce JSON/CSV files.
   - What's unclear: Whether users expect a save dialog or share sheet.
   - Recommendation: Use share sheet (share_plus) for mobile; consider file picker only if desktop-focused.

2. **Week start day definition**
   - What we know: Weekly reports need daily breakdowns.
   - What's unclear: Should weeks start Monday or Sunday.
   - Recommendation: Default to Monday (ISO-8601) unless product spec says otherwise.

## Sources

### Primary (HIGH confidence)
- https://pub.dev/packages/shared_preferences - usage, storage notes, new APIs
- https://pub.dev/packages/flutter_riverpod - package overview and usage
- https://pub.dev/packages/csv - CSV conversion APIs
- https://pub.dev/packages/path_provider - filesystem directories
- https://pub.dev/packages/share_plus - sharing files via OS share UI
- https://api.dart.dev/stable/3.10.8/dart-convert/ - JSON encoding/decoding

### Secondary (MEDIUM confidence)
- https://riverpod.dev/docs/introduction/getting_started - provider usage patterns

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - verified via pub.dev and SDK docs
- Architecture: MEDIUM - based on Riverpod patterns + app structure
- Pitfalls: MEDIUM - based on platform behavior and reporting domain heuristics

**Research date:** 2026-01-30
**Valid until:** 2026-02-28
