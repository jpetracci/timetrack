import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report_models.dart';
import '../../state/settings_controller.dart';

class ReportTable extends ConsumerWidget {
  const ReportTable({
    super.key,
    required this.data,
    this.title,
  });

  final List<ReportProjectTotal> data;
  final String? title;

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
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'No time entries for this period.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
          ],
          DataTable(
            columns: const [
              DataColumn(
                label: Text('Project'),
                tooltip: 'Project name',
              ),
              DataColumn(
                label: Text('Hours'),
                numeric: true,
                tooltip: 'Total hours spent',
              ),
            ],
            rows: [
              // Data rows
              ...data.map<DataRow>((ReportProjectTotal item) {
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
                  ],
                );
              }),
              
              // Total row
              DataRow.byIndex(
                index: data.length,
                selected: false,
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDecimalHours(double hours, int precision) {
    return hours.toStringAsFixed(precision);
  }
}