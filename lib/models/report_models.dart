import 'package:flutter/foundation.dart';

/// Represents a project's total time for a specific period
@immutable
class ReportProjectTotal {
  const ReportProjectTotal({
    required this.projectId,
    required this.projectName,
    required this.duration,
  });

  final String projectId;
  final String projectName;
  final Duration duration;

  /// Duration in decimal hours (e.g., 2.5 for 2 hours 30 minutes)
  double get durationHours {
    return duration.inMilliseconds / Duration.millisecondsPerHour;
  }

  ReportProjectTotal copyWith({
    String? projectId,
    String? projectName,
    Duration? duration,
  }) {
    return ReportProjectTotal(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportProjectTotal &&
        other.projectId == projectId &&
        other.projectName == projectName &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(projectId, projectName, duration);

  @override
  String toString() {
    return 'ReportProjectTotal(projectId: $projectId, projectName: $projectName, duration: $duration)';
  }
}

/// Represents a project's breakdown across multiple days (e.g., weekly report)
@immutable
class WeeklyProjectBreakdown {
  const WeeklyProjectBreakdown({
    required this.projectId,
    required this.projectName,
    required this.dailyDurations,
    required this.totalDuration,
  });

  final String projectId;
  final String projectName;
  final Map<DateTime, Duration> dailyDurations;
  final Duration totalDuration;

  /// Duration in decimal hours
  double get durationHours {
    return totalDuration.inMilliseconds / Duration.millisecondsPerHour;
  }

  WeeklyProjectBreakdown copyWith({
    String? projectId,
    String? projectName,
    Map<DateTime, Duration>? dailyDurations,
    Duration? totalDuration,
  }) {
    return WeeklyProjectBreakdown(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      dailyDurations: dailyDurations ?? this.dailyDurations,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyProjectBreakdown &&
        other.projectId == projectId &&
        other.projectName == projectName &&
        mapEquals(other.dailyDurations, dailyDurations) &&
        other.totalDuration == totalDuration;
  }

  @override
  int get hashCode => Object.hash(projectId, projectName, dailyDurations, totalDuration);

  @override
  String toString() {
    return 'WeeklyProjectBreakdown(projectId: $projectId, projectName: $projectName, totalDuration: $totalDuration)';
  }
}

/// Simple date range utility
class DateRange {
  const DateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() {
    return 'DateRange(start: $start, end: $end)';
  }
}