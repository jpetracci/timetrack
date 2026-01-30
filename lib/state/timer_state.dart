import '../models/time_entry.dart';

class TimerState {
  const TimerState({
    required this.entries,
    required this.runningEntry,
    required this.activeProjectId,
    required this.startTime,
    required this.elapsed,
  });

  final List<TimeEntry> entries;
  final TimeEntry? runningEntry;
  final String? activeProjectId;
  final DateTime? startTime;
  final Duration elapsed;

  bool get isRunning => runningEntry != null;

  factory TimerState.initial() {
    return const TimerState(
      entries: [],
      runningEntry: null,
      activeProjectId: null,
      startTime: null,
      elapsed: Duration.zero,
    );
  }

  TimerState copyWith({
    List<TimeEntry>? entries,
    TimeEntry? runningEntry,
    String? activeProjectId,
    DateTime? startTime,
    Duration? elapsed,
  }) {
    return TimerState(
      entries: entries ?? this.entries,
      runningEntry: runningEntry ?? this.runningEntry,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}
