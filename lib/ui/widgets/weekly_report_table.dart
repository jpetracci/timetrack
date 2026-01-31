import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report_models.dart';
import '../../state/settings_controller.dart';

class WeeklyReportTable extends ConsumerWidget {
  const WeeklyReportTable({
    super.key,
    required this.data,
    required this.weekStart,
  });

  final List<WeeklyProjectBreakdown> data;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final precision = settingsState.precision;

    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'No time entries for this week.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track some time to see weekly reports here.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Generate day labels for the week
    final weekDays = <String>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      weekDays.add(_formatDayLabel(day));
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header with week info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week of ${_formatWeekStart(weekStart)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateRange(weekStart, weekStart.add(const Duration(days: 6))),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              horizontalMargin: 16.0,
              columns: [
                const DataColumn(
                  label: Text('Project'),
                  tooltip: 'Project name',
                ),
                const DataColumn(
                  label: Text('Total'),
                  numeric: true,
                  tooltip: 'Total hours for the week',
                ),
                // Day columns
                ...weekDays.asMap().entries.map<DataColumn>((entry) {
                  return DataColumn(
                    label: Text(entry.value),
                    numeric: true,
                    tooltip: entry.value,
                  );
                }),
              ],
              rows: [
                // Data rows
                ...data.map((WeeklyProjectBreakdown item) {
                  return DataRow.byIndex(
                    index: data.indexOf(item),
                    cells: [
                      DataCell(Text(item.projectName)),
                      DataCell(
                        Text(
                          _formatDecimalHours(item.durationHours, precision),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      // Day columns
                      ...weekDays.asMap().entries.map<DataCell>((dayEntry) {
                        final dayIndex = dayEntry.key;
                        final dayDate = weekStart.add(Duration(days: dayIndex));
                        final dayDuration = item.dailyDurations[dayDate] ?? Duration.zero;
                        
                        return DataCell(
                          Text(
                            _formatDecimalHours(
                              dayDuration.inMilliseconds / Duration.millisecondsPerHour,
                              precision,
                            ),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        );
                  }),
                    ],
                  );
                }),
                
                // Total row
                DataRow.byIndex(
                  index: data.length,
                  color: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  ),
                  cells: [
                    DataCell(
                      Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDecimalHours(
                          data.fold<double>(0, (sum, item) => sum + item.durationHours),
                          precision,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    // Day totals
                    ...weekDays.asMap().entries.map<DataCell>((dayEntry) {
                      final dayIndex = dayEntry.key;
                      final dayDate = weekStart.add(Duration(days: dayIndex));
                      
                      final dayTotal = data.fold<double>(0, (sum, item) {
                        final dayDuration = item.dailyDurations[dayDate] ?? Duration.zero;
                        return sum + (dayDuration.inMilliseconds / Duration.millisecondsPerHour);
                      });
                      
                      return DataCell(
                        Text(
                          _formatDecimalHours(dayTotal, precision),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                      }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDecimalHours(double hours, int precision) {
    return hours.toStringAsFixed(precision);
  }

  String _formatDayLabel(DateTime day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day.weekday - 1];
  }

  String _formatWeekStart(DateTime weekStart) {
    return '${_monthName(weekStart.month)} ${weekStart.day}, ${weekStart.year}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${_monthName(start.month)} ${start.day}-${end.day}';
    } else {
      return '${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}