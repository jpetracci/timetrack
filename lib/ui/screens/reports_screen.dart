import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reporting_controller.dart';
import '../../state/reporting_state.dart';
import '../../models/report_models.dart';

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
                child: _buildReportContent(context, reportingState),
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

  Widget _buildReportContent(BuildContext context, ReportingState state) {
    // Placeholder for now - will be implemented in Task 2
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
            'Reports coming soon...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View: ${state.view.displayName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Range: ${_formatDateRange(state.range)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
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
