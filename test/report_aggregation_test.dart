import 'package:flutter_test/flutter_test.dart';
import 'package:timetrack/models/time_entry.dart';
import 'package:timetrack/models/project.dart';
import 'package:timetrack/models/report_models.dart';
import 'package:timetrack/utils/report_aggregation.dart';

void main() {
  group('Report Aggregation Tests', () {
    late List<Project> projects;
    late List<TimeEntry> entries;

    setUp(() {
      projects = [
        Project(
          id: 'proj1',
          name: 'Project One',
          tags: ['work'],
          createdAt: DateTime(2026, 1, 15),
        ),
        Project(
          id: 'proj2',
          name: 'Project Two',
          tags: ['personal'],
          createdAt: DateTime(2026, 1, 16),
        ),
      ];
    });

    group('Daily Totals', () {
      test('returns correct per-project hours for entries on same day', () {
        entries = [
          TimeEntry(
            id: 'entry1',
            projectId: 'proj1',
            start: DateTime(2026, 1, 20, 9, 0),
            end: DateTime(2026, 1, 20, 11, 30), // 2.5 hours
          ),
          TimeEntry(
            id: 'entry2',
            projectId: 'proj2',
            start: DateTime(2026, 1, 20, 13, 0),
            end: DateTime(2026, 1, 20, 15, 0), // 2.0 hours
          ),
          TimeEntry(
            id: 'entry3',
            projectId: 'proj1',
            start: DateTime(2026, 1, 20, 15, 30),
            end: DateTime(2026, 1, 20, 17, 0), // 1.5 hours
          ),
        ];

        final report = buildDailyReport(projects, entries, DateTime(2026, 1, 20));

        expect(report.length, 2);
        
        final proj1Total = report.firstWhere((r) => r.projectId == 'proj1');
        final proj2Total = report.firstWhere((r) => r.projectId == 'proj2');

        expect(proj1Total.projectName, 'Project One');
        expect(proj1Total.duration.inHours, 4); // 2.5 + 1.5 = 4.0 hours
        expect(proj1Total.duration.inMinutes % 60, 0);

        expect(proj2Total.projectName, 'Project Two');
        expect(proj2Total.duration.inHours, 2); // 2.0 hours
      });

      test('ignores entries from other days', () {
        entries = [
          TimeEntry(
            id: 'entry1',
            projectId: 'proj1',
            start: DateTime(2026, 1, 20, 9, 0),
            end: DateTime(2026, 1, 20, 11, 0),
          ),
          TimeEntry(
            id: 'entry2',
            projectId: 'proj1',
            start: DateTime(2026, 1, 19, 9, 0), // Previous day
            end: DateTime(2026, 1, 19, 11, 0),
          ),
        ];

        final report = buildDailyReport(projects, entries, DateTime(2026, 1, 20));

        expect(report.length, 1);
        expect(report.first.projectId, 'proj1');
        expect(report.first.duration.inHours, 2);
      });

      test('returns empty list for day with no entries', () {
        final report = buildDailyReport(projects, [], DateTime(2026, 1, 20));

        expect(report, isEmpty);
      });
    });

    group('Midnight Split', () {
      test('splits entry spanning midnight across two days correctly', () {
        entries = [
          TimeEntry(
            id: 'entry1',
            projectId: 'proj1',
            start: DateTime(2026, 1, 20, 23, 0),
            end: DateTime(2026, 1, 21, 1, 0), // Spans midnight
          ),
        ];

        // Test split for first day (should show 1 hour)
        final day1Report = buildDailyReport(projects, entries, DateTime(2026, 1, 20));
        expect(day1Report.length, 1);
        expect(day1Report.first.duration.inHours, 1);

        // Test split for second day (should show 1 hour)
        final day2Report = buildDailyReport(projects, entries, DateTime(2026, 1, 21));
        expect(day2Report.length, 1);
        expect(day2Report.first.duration.inHours, 1);
      });

      test('handles entry spanning multiple midnights', () {
        entries = [
          TimeEntry(
            id: 'entry1',
            projectId: 'proj1',
            start: DateTime(2026, 1, 20, 22, 0),
            end: DateTime(2026, 1, 22, 2, 0), // Spans 2 midnights
          ),
        ];

        // Day 1: 22:00-24:00 = 2 hours
        final day1Report = buildDailyReport(projects, entries, DateTime(2026, 1, 20));
        expect(day1Report.first.duration.inHours, 2);

        // Day 2: 00:00-24:00 = 24 hours
        final day2Report = buildDailyReport(projects, entries, DateTime(2026, 1, 21));
        expect(day2Report.first.duration.inHours, 24);

        // Day 3: 00:00-02:00 = 2 hours
        final day3Report = buildDailyReport(projects, entries, DateTime(2026, 1, 22));
        expect(day3Report.first.duration.inHours, 2);
      });
    });

    group('Weekly Breakdown', () {
      test('returns per-project totals with daily breakdowns', () {
        entries = [
          // Monday: Project 1 from 9-11, Project 2 from 13-15
          TimeEntry(
            id: 'entry1',
            projectId: 'proj1',
            start: DateTime(2026, 1, 19, 9, 0), // Monday
            end: DateTime(2026, 1, 19, 11, 0),
          ),
          TimeEntry(
            id: 'entry2',
            projectId: 'proj2',
            start: DateTime(2026, 1, 19, 13, 0), // Monday
            end: DateTime(2026, 1, 19, 15, 0),
          ),
          // Tuesday: Project 1 from 10-12
          TimeEntry(
            id: 'entry3',
            projectId: 'proj1',
            start: DateTime(2026, 1, 20, 10, 0), // Tuesday
            end: DateTime(2026, 1, 20, 12, 0),
          ),
        ];

        final weeklyReport = buildWeeklyReport(projects, entries, DateTime(2026, 1, 19)); // Monday start

        expect(weeklyReport.length, 2);

        final proj1Breakdown = weeklyReport.firstWhere((r) => r.projectId == 'proj1');
        final proj2Breakdown = weeklyReport.firstWhere((r) => r.projectId == 'proj2');

        // Check Project 1 breakdown
        expect(proj1Breakdown.projectName, 'Project One');
        expect(proj1Breakdown.totalDuration.inHours, 4); // 2 + 2 hours
        expect(proj1Breakdown.dailyDurations[DateTime(2026, 1, 19)]?.inHours, 2); // Monday
        expect(proj1Breakdown.dailyDurations[DateTime(2026, 1, 20)]?.inHours, 2); // Tuesday

        // Check Project 2 breakdown
        expect(proj2Breakdown.projectName, 'Project Two');
        expect(proj2Breakdown.totalDuration.inHours, 2); // 2 hours
        expect(proj2Breakdown.dailyDurations[DateTime(2026, 1, 19)]?.inHours, 2); // Monday
      });

      test('handles empty week', () {
        final weeklyReport = buildWeeklyReport(projects, [], DateTime(2026, 1, 19));

        expect(weeklyReport, isEmpty);
      });

      test('excludes projects with zero total duration', () {
        entries = [
          TimeEntry(
            id: 'entry1',
            projectId: 'proj1',
            start: DateTime(2026, 1, 19, 9, 0),
            end: DateTime(2026, 1, 19, 9, 0), // Zero duration
          ),
        ];

        final weeklyReport = buildWeeklyReport(projects, entries, DateTime(2026, 1, 19));

        expect(weeklyReport, isEmpty);
      });
    });

    group('Unknown Project', () {
      test('maps unknown project ID to "Unknown project" label', () {
        entries = [
          TimeEntry(
            id: 'entry1',
            projectId: 'unknown_proj',
            start: DateTime(2026, 1, 20, 9, 0),
            end: DateTime(2026, 1, 20, 11, 0),
          ),
        ];

        final dailyReport = buildDailyReport(projects, entries, DateTime(2026, 1, 20));
        final weeklyReport = buildWeeklyReport(projects, entries, DateTime(2026, 1, 19));

        expect(dailyReport.length, 1);
        expect(dailyReport.first.projectId, 'unknown_proj');
        expect(dailyReport.first.projectName, 'Unknown project');
        expect(dailyReport.first.duration.inHours, 2);

        expect(weeklyReport.length, 1);
        expect(weeklyReport.first.projectId, 'unknown_proj');
        expect(weeklyReport.first.projectName, 'Unknown project');
      });
    });

    group('Helper Functions', () {
      test('normalizeDay returns midnight for given datetime', () {
        final input = DateTime(2026, 1, 20, 15, 30, 45);
        final normalized = normalizeDay(input);

        expect(normalized.year, 2026);
        expect(normalized.month, 1);
        expect(normalized.day, 20);
        expect(normalized.hour, 0);
        expect(normalized.minute, 0);
        expect(normalized.second, 0);
        expect(normalized.millisecond, 0);
      });

      test('daysInRange returns inclusive list of days', () {
        final start = DateTime(2026, 1, 20);
        final end = DateTime(2026, 1, 22);
        final range = DateRange(start: start, end: end);

        final days = daysInRange(range);

        expect(days.length, 3);
        expect(days[0], DateTime(2026, 1, 20));
        expect(days[1], DateTime(2026, 1, 21));
        expect(days[2], DateTime(2026, 1, 22));
      });

      test('splitEntryByDay splits entry across day boundaries', () {
        final entry = TimeEntry(
          id: 'entry1',
          projectId: 'proj1',
          start: DateTime(2026, 1, 20, 23, 0),
          end: DateTime(2026, 1, 21, 1, 30),
        );

        final split = splitEntryByDay(entry);

        expect(split.keys.length, 2);
        expect(split[DateTime(2026, 1, 20)]?.inHours, 1);
        expect(split[DateTime(2026, 1, 21)]?.inMinutes, 90); // 1.5 hours
      });

      test('splitEntryByDay handles same-day entry', () {
        final entry = TimeEntry(
          id: 'entry1',
          projectId: 'proj1',
          start: DateTime(2026, 1, 20, 9, 0),
          end: DateTime(2026, 1, 20, 11, 30),
        );

        final split = splitEntryByDay(entry);

        expect(split.keys.length, 1);
        expect(split[DateTime(2026, 1, 20)]?.inMinutes, 150); // 2.5 hours
      });
    });
  });
}