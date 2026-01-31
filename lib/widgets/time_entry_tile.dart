import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/time_entry.dart';
import '../state/timer_controller.dart';
import '../utils/decimal_time.dart';

class TimeEntryTile extends ConsumerWidget {
  const TimeEntryTile({
    super.key,
    required this.entry,
    required this.precision,
  });

  final TimeEntry entry;
  final int precision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onPressed: entry.isRunning
                    ? null
                    : () => _showEditSheet(context, ref),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit duration',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: entry.isRunning
                    ? null
                    : () => _confirmDelete(context, ref),
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

  String _formatHours(Duration duration, int precision) {
    final double hours = duration.inMilliseconds / Duration.millisecondsPerHour;
    return hours.toStringAsFixed(precision);
  }

  Future<void> _showEditSheet(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController(
      text: _formatHours(entry.duration, precision),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Edit duration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Duration (hours)',
                  hintText: '1.5',
                ),
                onSubmitted: (_) => _submitDuration(context, ref, controller),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _submitDuration(context, ref, controller),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Future<void> _submitDuration(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
  ) async {
    final String raw = controller.text.trim();
    final double? hours = double.tryParse(raw);
    if (hours == null || hours <= 0) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a duration greater than 0.')),
      );
      return;
    }

    final Duration newDuration = Duration(
      milliseconds: (hours * Duration.millisecondsPerHour).round(),
    );

    try {
      await ref
          .read(timerControllerProvider.notifier)
          .updateEntryDuration(entry.id, newDuration);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update duration.')),
        );
      }
      return;
    }

    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete entry?'),
          content: const Text('This removes the entry from your history.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(timerControllerProvider.notifier).deleteEntry(entry.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete entry.')),
        );
      }
    }
  }
}
