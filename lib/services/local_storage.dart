import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';
import '../models/time_entry.dart';

class LocalStorage {
  static const String _projectsKey = 'projects';
  static const String _entriesKey = 'entries';
  static const String _activeTimerKey = 'active_timer';
  static const String _schemaVersionKey = 'schema_version';
  static const int _currentSchemaVersion = 2;

  Future<void> _migrateIfNeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedVersion = prefs.getInt(_schemaVersionKey) ?? 1;
    
    if (storedVersion >= _currentSchemaVersion) {
      return;
    }

    // Run migrations sequentially
    for (int version = storedVersion; version < _currentSchemaVersion; version++) {
      await _runMigration(version, version + 1);
    }

    // Update stored schema version
    await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
  }

  Future<void> _runMigration(int fromVersion, int toVersion) async {
    switch (fromVersion) {
      case 1:
        await _migrateFromV1ToV2();
        break;
      default:
        throw StateError('Unknown migration: $fromVersion -> $toVersion');
    }
  }

  Future<void> _migrateFromV1ToV2() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Migrate projects to add isArchived field
    final String? projectsRaw = prefs.getString(_projectsKey);
    if (projectsRaw != null && projectsRaw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(projectsRaw) as List<dynamic>;
        final List<Project> migratedProjects = decoded
            .map((dynamic item) {
              final Map<String, dynamic> json = item as Map<String, dynamic>;
              // Add missing isArchived field with default false
              if (!json.containsKey('isArchived')) {
                json['isArchived'] = false;
              }
              return Project.fromJson(json);
            })
            .toList();
        
        await prefs.setString(_projectsKey, jsonEncode(
          migratedProjects.map((Project p) => p.toJson()).toList(),
        ));
      } catch (e) {
        // If migration fails, continue with existing data
        // The next load attempt will use the current model's default handling
      }
    }

    // Migrate entries - no schema changes needed but reload to ensure consistency
    final String? entriesRaw = prefs.getString(_entriesKey);
    if (entriesRaw != null && entriesRaw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(entriesRaw) as List<dynamic>;
        final List<TimeEntry> migratedEntries = decoded
            .map((dynamic item) => TimeEntry.fromJson(item as Map<String, dynamic>))
            .toList();
        
        await prefs.setString(_entriesKey, jsonEncode(
          migratedEntries.map((TimeEntry e) => e.toJson()).toList(),
        ));
      } catch (e) {
        // If migration fails, continue with existing data
      }
    }
  }

  Future<List<Project>> loadProjects() async {
    await _migrateIfNeeded();
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_projectsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProjects(List<Project> projects) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      projects.map((Project project) => project.toJson()).toList(),
    );
    await prefs.setString(_projectsKey, encoded);
  }

  Future<List<TimeEntry>> loadEntries() async {
    await _migrateIfNeeded();
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => TimeEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEntries(List<TimeEntry> entries) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      entries.map((TimeEntry entry) => entry.toJson()).toList(),
    );
    await prefs.setString(_entriesKey, encoded);
  }

  Future<ActiveTimerSnapshot?> loadActiveTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_activeTimerKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;
    return ActiveTimerSnapshot(
      projectId: decoded['projectId'] as String,
      start: DateTime.parse(decoded['start'] as String),
    );
  }

  Future<void> saveActiveTimer({
    required String projectId,
    required DateTime start,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode({
      'projectId': projectId,
      'start': start.toIso8601String(),
    });
    await prefs.setString(_activeTimerKey, encoded);
  }

  Future<void> clearActiveTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeTimerKey);
  }
}

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

class ActiveTimerSnapshot {
  const ActiveTimerSnapshot({
    required this.projectId,
    required this.start,
  });

  final String projectId;
  final DateTime start;
}
