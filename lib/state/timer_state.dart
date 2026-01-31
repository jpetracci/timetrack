import '../models/time_entry.dart';

class TimerState {
  static const Object _unset = Object();
  const TimerState({
    required this.entries,
    required this.runningEntry,
    required this.activeProjectId,
    required this.lastActiveProjectId,
    required this.startTime,
    required this.elapsed,
  });

  final List<TimeEntry> entries;
  final TimeEntry? runningEntry;
  final String? activeProjectId;
  final String? lastActiveProjectId;
  final DateTime? startTime;
  final Duration elapsed;

  bool get isRunning => runningEntry != null;

  factory TimerState.initial() {
    return const TimerState(
      entries: [],
      runningEntry: null,
      activeProjectId: null,
      lastActiveProjectId: null,
      startTime: null,
      elapsed: Duration.zero,
    );
  }

  TimerState copyWith({
    List<TimeEntry>? entries,
    Object? runningEntry = _unset,
    Object? activeProjectId = _unset,
    Object? lastActiveProjectId = _unset,
    Object? startTime = _unset,
    Duration? elapsed,
  }) {
    return TimerState(
      entries: entries ?? this.entries,
      runningEntry: runningEntry == _unset
          ? this.runningEntry
          : runningEntry as TimeEntry?,
      activeProjectId: activeProjectId == _unset
          ? this.activeProjectId
          : activeProjectId as String?,
      lastActiveProjectId: lastActiveProjectId == _unset
          ? this.lastActiveProjectId
          : lastActiveProjectId as String?,
      startTime: startTime == _unset
          ? this.startTime
          : startTime as DateTime?,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}
