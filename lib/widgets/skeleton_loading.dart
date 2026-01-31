import 'package:flutter/material.dart';

/// Skeleton loading widget for time entries
class TimeEntrySkeleton extends StatelessWidget {
  const TimeEntrySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSkeleton(width: 60, height: 14),
              const Spacer(),
              _buildSkeleton(width: 40, height: 14),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeleton(width: 80, height: 18),
                    const SizedBox(height: 4),
                    _buildSkeleton(width: 40, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSkeleton(width: 80, height: 18),
                    const SizedBox(height: 4),
                    _buildSkeleton(width: 40, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton widget for report data
class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeleton(width: 120, height: 20),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _buildSkeleton(width: 100, height: 16),
                  const Spacer(),
                  _buildSkeleton(width: 60, height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Animated loading indicator with better UX
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized list view that handles loading states gracefully
class OptimizedListView<T> extends StatelessWidget {
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loading = false,
    this.skeletonBuilder,
    this.padding,
    this.separator,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool loading;
  final Widget Function(BuildContext context, int index)? skeletonBuilder;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context, int index)? separator;

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return LoadingIndicator(message: 'Loading data...');
    }

    final itemCount = items.length + (items.isEmpty ? 1 : 0);
    
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          if (items.isEmpty) {
            return _buildEmptyState(context);
          }
          return const SizedBox.shrink();
        }

        final item = items[index];
        final widget = itemBuilder(context, item, index);
        
        if (separator != null && index < items.length - 1) {
          return Column(
            children: [
              widget,
              separator!(context, index),
            ],
          );
        }
        
        return widget;
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}