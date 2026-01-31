import 'package:flutter/material.dart';

import '../models/time_entry.dart';
import '../utils/decimal_time.dart';

class TimeEntryTile extends StatelessWidget {
  const TimeEntryTile({
    super.key,
    required this.entry,
    required this.precision,
    this.onEdit,
    this.onDelete,
  });

  final TimeEntry entry;
  final int precision;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String dateLabel = _formatDate(entry.start);
    final String startTime = _formatTime(context, entry.start);
    final String endTime =
        entry.end == null ? 'Running' : _formatTime(context, entry.end!);
    final String durationLabel = formatDecimalHours(entry.duration, precision);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (entry.isRunning)
                Text(
                  'Running',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                      ),
                ),
              if (entry.isRunning) const SizedBox(width: 8),
              Text(
                durationLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      startTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Start',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      endTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      entry.end == null ? 'Running' : 'End',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit duration',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete entry',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String _formatTime(BuildContext context, DateTime value) {
    return TimeOfDay.fromDateTime(value.toLocal()).format(context);
  }
}
