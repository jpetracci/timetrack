import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/time_entry.dart';
import '../services/local_storage.dart';
import 'projects_state.dart';
import 'timer_state.dart';

class TimerController extends Notifier<TimerState> {
  final Uuid _uuid = const Uuid();
  Timer? _ticker;

  LocalStorage get _storage => ref.read(localStorageProvider);
  ProjectsController get _projectsController =>
      ref.read(projectsControllerProvider.notifier);

  @override
  TimerState build() {
    ref.onDispose(_stopTicker);
    return TimerState.initial();
  }

  Future<void> hydrate() async {
    final List<TimeEntry> entries = await _storage.loadEntries();
    final ActiveTimerSnapshot? snapshot = await _storage.loadActiveTimer();
    if (snapshot == null) {
      state = state.copyWith(entries: entries);
      return;
    }

    final DateTime now = DateTime.now();
    final TimeEntry runningEntry = TimeEntry(
      id: _uuid.v4(),
      projectId: snapshot.projectId,
      start: snapshot.start,
    );

    state = state.copyWith(
      entries: entries,
      runningEntry: runningEntry,
      activeProjectId: snapshot.projectId,
      startTime: snapshot.start,
      elapsed: now.difference(snapshot.start),
    );
    _projectsController.setActiveProject(snapshot.projectId);
    _startTicker();
  }

  Future<void> start(String projectId) async {
    if (state.isRunning) {
      if (state.activeProjectId == projectId) {
        return;
      }
      await switchTo(projectId);
      return;
    }

    final DateTime now = DateTime.now();
    final TimeEntry runningEntry = TimeEntry(
      id: _uuid.v4(),
      projectId: projectId,
      start: now,
    );

    state = state.copyWith(
      runningEntry: runningEntry,
      activeProjectId: projectId,
      startTime: now,
      elapsed: Duration.zero,
    );

    await _storage.saveEntries(state.entries);
    await _storage.saveActiveTimer(projectId: projectId, start: now);
    _projectsController.setActiveProject(projectId);
    _startTicker();
  }

  Future<void> stop() async {
    if (!state.isRunning || state.runningEntry == null) {
      return;
    }

    final DateTime now = DateTime.now();
    final TimeEntry completed = state.runningEntry!.copyWith(end: now);
    final List<TimeEntry> updatedEntries = [...state.entries, completed];

    _stopTicker();
    state = state.copyWith(
      entries: updatedEntries,
      runningEntry: null,
      activeProjectId: null,
      startTime: null,
      elapsed: Duration.zero,
    );

    await _storage.saveEntries(updatedEntries);
    await _storage.clearActiveTimer();
    _projectsController.setActiveProject(null);
  }

  Future<void> switchTo(String projectId) async {
    if (!state.isRunning) {
      await start(projectId);
      return;
    }

    if (state.activeProjectId == projectId) {
      return;
    }

    await stop();
    await start(projectId);
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final DateTime? startTime = state.startTime;
      if (startTime == null) {
        return;
      }
      state = state.copyWith(elapsed: DateTime.now().difference(startTime));
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

}

final timerControllerProvider =
    NotifierProvider<TimerController, TimerState>(TimerController.new);
