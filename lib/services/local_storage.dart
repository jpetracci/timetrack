import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';
import '../models/time_entry.dart';

class LocalStorage {
  static const String _projectsKey = 'projects';
  static const String _entriesKey = 'entries';
  static const String _activeTimerKey = 'active_timer';

  Future<List<Project>> loadProjects() async {
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
