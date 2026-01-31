import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reporting_controller.dart';
import '../../state/reporting_state.dart';
import '../../state/timer_controller.dart';
import '../../state/projects_state.dart';
import '../../models/report_models.dart';
import '../../models/time_entry.dart';
import '../../utils/report_aggregation.dart';
import '../../utils/performance_monitor.dart';
import '../widgets/report_table.dart';
import '../widgets/weekly_report_table.dart';

/// Helper class to group daily report data
class DailyReportData {
  const DailyReportData({
    required this.date,
    required this.report,
  });

  final DateTime date;
  final List<ReportProjectTotal> report;
}

/// Helper class to group weekly report data
class WeeklyReportData {
  const WeeklyReportData({
    required this.weekStart,
    required this.report,
  });

  final DateTime weekStart;
  final List<WeeklyProjectBreakdown> report;
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportingState = ref.watch(reportingControllerProvider);
    final reportingController = ref.read(reportingControllerProvider.notifier);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              // View toggle and date range controls
              _buildHeaderControls(context, reportingState, reportingController),
              
              const SizedBox(height: 16),
              
              // Report content will go here
              Expanded(
                child: _buildReportContent(context, ref, reportingState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderControls(
    BuildContext context,
    ReportingState state,
    ReportingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // View toggle
        SegmentedButton<ReportView>(
          segments: const [
            ButtonSegment<ReportView>(
              value: ReportView.daily,
              label: Text('Daily'),
              icon: Icon(Icons.calendar_today),
            ),
            ButtonSegment<ReportView>(
              value: ReportView.weekly,
              label: Text('Weekly'),
              icon: Icon(Icons.date_range),
            ),
          ],
          selected: <ReportView>{state.view},
          onSelectionChanged: (Set<ReportView> selection) {
            if (selection.isNotEmpty) {
              controller.setView(selection.first);
            }
          },
        ),
        
        const SizedBox(height: 12),
        
        // Date range and quick actions
        Row(
          children: [
            // Date range display chip
            Expanded(
              child: InputChip(
                avatar: const Icon(Icons.calendar_month),
                label: Text(_formatDateRange(state.range)),
                onPressed: () => _showDateRangePicker(context, controller, state.range),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Quick action buttons
            IconButton.outlined(
              onPressed: controller.setToday,
              icon: const Icon(Icons.today),
              tooltip: 'Today',
            ),
            const SizedBox(width: 4),
            IconButton.outlined(
              onPressed: controller.setThisWeek,
              icon: const Icon(Icons.view_week),
              tooltip: 'This Week',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportContent(BuildContext context, WidgetRef ref, ReportingState state) {
    switch (state.view) {
      case ReportView.daily:
        return _buildDailyView(context, ref, state);
      case ReportView.weekly:
        return _buildWeeklyView(context, ref, state);
    }
  }

  Widget _buildDailyView(BuildContext context, WidgetRef ref, ReportingState state) {
    final timerState = ref.watch(timerControllerProvider);
    final projectsState = ref.watch(projectsControllerProvider);
    
    // Combine entries with running entry
    final List<TimeEntry> allEntries = List.from(timerState.entries);
    if (timerState.runningEntry != null) {
      allEntries.add(timerState.runningEntry!);
    }

    // Track performance for data processing
    PerformanceTracker.trackDataProcessing('daily report aggregation', allEntries.length);

    final days = daysInRange(state.range);
    final List<DailyReportData> dailyReports = [];

    for (final day in days) {
      final reportData = buildDailyReport(projectsState.projects, allEntries, day);
      if (reportData.isNotEmpty) {
        dailyReports.add(DailyReportData(
          date: day,
          report: reportData,
        ));
      }
    }

    if (dailyReports.isEmpty) {
      return _buildEmptyState(context, 'No time entries for this period');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          PerformanceTracker.trackScrollPerformance('daily reports', scrollNotification.metrics.pixels);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: dailyReports.length,
        itemBuilder: (context, index) {
          final dailyData = dailyReports[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ReportTable(
              title: _formatDayDate(dailyData.date),
              data: dailyData.report,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyView(BuildContext context, WidgetRef ref, ReportingState state) {
    final timerState = ref.watch(timerControllerProvider);
    final projectsState = ref.watch(projectsControllerProvider);
    
    // Combine entries with running entry
    final List<TimeEntry> allEntries = List.from(timerState.entries);
    if (timerState.runningEntry != null) {
      allEntries.add(timerState.runningEntry!);
    }

    // Track performance for data processing
    PerformanceTracker.trackDataProcessing('weekly report aggregation', allEntries.length);

    // Calculate week starts within the selected range
    final List<DateTime> weekStarts = [];
    DateTime currentWeekStart = _getMonday(state.range.start);
    
    while (currentWeekStart.isBefore(state.range.end) || currentWeekStart.isAtSameMomentAs(state.range.end)) {
      if (currentWeekStart.isAfter(state.range.start) || currentWeekStart.isAtSameMomentAs(state.range.start)) {
        weekStarts.add(currentWeekStart);
      }
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    if (weekStarts.isEmpty) {
      return _buildEmptyState(context, 'No weeks in this period');
    }

    final List<WeeklyReportData> weeklyReports = [];

    for (final weekStart in weekStarts) {
      final reportData = buildWeeklyReport(projectsState.projects, allEntries, weekStart);
      if (reportData.isNotEmpty) {
        weeklyReports.add(WeeklyReportData(
          weekStart: weekStart,
          report: reportData,
        ));
      }
    }

    if (weeklyReports.isEmpty) {
      return _buildEmptyState(context, 'No time entries for this period');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          PerformanceTracker.trackScrollPerformance('weekly reports', scrollNotification.metrics.pixels);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: weeklyReports.length,
        itemBuilder: (context, index) {
          final weeklyData = weeklyReports[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
          child: WeeklyReportTable(
            data: weeklyData.report,
            weekStart: weeklyData.weekStart,
          ),
        );
      },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track some time to see reports here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getMonday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final monday = normalized.subtract(Duration(days: normalized.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  String _formatDayDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateRange(DateRange range) {
    final start = range.start;
    final end = range.end;
    
    if (start.year == end.year && start.month == end.month) {
      if (start.day == end.day) {
        // Same day: "Jan 15"
        return '${_monthName(start.month)} ${start.day}';
      } else {
        // Same month: "Jan 15-21"
        return '${_monthName(start.month)} ${start.day}-${end.day}';
      }
    } else if (start.year == end.year) {
      // Same year: "Jan 15 - Feb 21"
      return '${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}';
    } else {
      // Different years: "Dec 15, 2023 - Jan 21, 2024"
      return '${_monthName(start.month)} ${start.day}, ${start.year} - ${_monthName(end.month)} ${end.day}, ${end.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    ReportingController controller,
    DateRange currentRange,
  ) async {
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: currentRange.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (startDate == null) return;

    if (!context.mounted) return;

    final DateTime? endDate = await showDatePicker(
      context: context,
      initialDate: currentRange.end.isBefore(startDate) ? startDate : currentRange.end,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (endDate != null) {
      controller.setRange(DateRange(
        start: startDate,
        end: endDate,
      ));
    }
  }
}
