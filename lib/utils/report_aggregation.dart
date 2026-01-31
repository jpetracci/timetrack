import 'dart:collection';
import 'package:timetrack/models/time_entry.dart';
import 'package:timetrack/models/project.dart';
import 'package:timetrack/models/report_models.dart';

/// Normalizes a DateTime to midnight (00:00:00) of the same day in local time
DateTime normalizeDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

/// Returns an inclusive list of days in the given range
List<DateTime> daysInRange(DateRange range) {
  final List<DateTime> days = [];
  DateTime current = normalizeDay(range.start);
  final end = normalizeDay(range.end);

  while (!current.isAfter(end)) {
    days.add(current);
    current = current.add(const Duration(days: 1));
  }

  return days;
}

/// Splits a time entry into durations per day, handling midnight boundaries
Map<DateTime, Duration> splitEntryByDay(TimeEntry entry) {
  final Map<DateTime, Duration> split = {};
  
  if (entry.end == null) {
    // For running entries, use current time as end
    return split;
  }

  DateTime currentStart = entry.start;
  DateTime currentEnd = entry.end!;
  
  while (currentStart.isBefore(currentEnd)) {
    final DateTime dayStart = normalizeDay(currentStart);
    final DateTime nextDay = dayStart.add(const Duration(days: 1));
    final DateTime dayEnd = currentEnd.isBefore(nextDay) ? currentEnd : nextDay;
    
    final Duration dayDuration = dayEnd.difference(currentStart);
    if (dayDuration.inMilliseconds > 0) {
      split[dayStart] = (split[dayStart] ?? Duration.zero) + dayDuration;
    }
    
    currentStart = dayEnd;
  }

  return split;
}

/// Builds a daily report showing total time per project for the specified day
List<ReportProjectTotal> buildDailyReport(
  List<Project> projects,
  List<TimeEntry> entries,
  DateTime day,
) {
  final Map<String, Duration> projectDurations = {};
  final targetDay = normalizeDay(day);

  // Sum durations for each project on the target day
  for (final entry in entries) {
    if (entry.end == null) continue; // Skip running entries
    
    final split = splitEntryByDay(entry);
    final dayDuration = split[targetDay];
    if (dayDuration != null && dayDuration.inMilliseconds > 0) {
      projectDurations[entry.projectId] = 
          (projectDurations[entry.projectId] ?? Duration.zero) + dayDuration;
    }
  }

  // Create report totals
  final List<ReportProjectTotal> report = [];
  for (final entry in projectDurations.entries) {
    final duration = entry.value;
    if (duration.inMilliseconds == 0) continue; // Skip zero-duration
    
    final project = projects.where((p) => p.id == entry.key).firstOrNull;
    final projectName = project?.name ?? 'Unknown project';
    
    report.add(ReportProjectTotal(
      projectId: entry.key,
      projectName: projectName,
      duration: duration,
    ));
  }

  // Sort by duration descending
  report.sort((a, b) => b.duration.inMilliseconds.compareTo(a.duration.inMilliseconds));
  
  return report;
}

/// Builds a weekly report with daily breakdowns per project
List<WeeklyProjectBreakdown> buildWeeklyReport(
  List<Project> projects,
  List<TimeEntry> entries,
  DateTime weekStart,
) {
  final Map<String, Map<DateTime, Duration>> projectDailyDurations = {};
  
  // Build 7-day range starting from weekStart (assumed to be Monday)
  final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  // Split all entries by day
  for (final entry in entries) {
    if (entry.end == null) continue; // Skip running entries
    
    final split = splitEntryByDay(entry);
    for (final dayEntry in split.entries) {
      final day = dayEntry.key;
      if (day.isAfter(weekEnd) || day.isBefore(weekStart)) continue;
      
      projectDailyDurations.putIfAbsent(entry.projectId, () => {});
      projectDailyDurations[entry.projectId]![day] = 
          (projectDailyDurations[entry.projectId]![day] ?? Duration.zero) + dayEntry.value;
    }
  }

  // Create weekly breakdowns
  final List<WeeklyProjectBreakdown> report = [];
  for (final projectEntry in projectDailyDurations.entries) {
    final dailyDurations = projectEntry.value;
    
    // Calculate total duration for the project
    Duration totalDuration = Duration.zero;
    for (final dayDuration in dailyDurations.values) {
      totalDuration += dayDuration;
    }
    
    if (totalDuration.inMilliseconds == 0) continue; // Skip zero-duration
    
    final project = projects.where((p) => p.id == projectEntry.key).firstOrNull;
    final projectName = project?.name ?? 'Unknown project';
    
    report.add(WeeklyProjectBreakdown(
      projectId: projectEntry.key,
      projectName: projectName,
      dailyDurations: dailyDurations,
      totalDuration: totalDuration,
    ));
  }

  // Sort by total duration descending
  report.sort((a, b) => b.totalDuration.inMilliseconds.compareTo(a.totalDuration.inMilliseconds));
  
  return report;
}