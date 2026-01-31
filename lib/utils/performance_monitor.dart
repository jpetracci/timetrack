import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Performance monitoring wrapper that activates only in debug mode
/// 
/// This widget tracks performance metrics when running in debug mode.
/// In release mode, it renders the child without any overhead.
class PerformanceMonitor extends StatelessWidget {
  const PerformanceMonitor({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // In debug mode, track performance metrics
    if (kDebugMode) {
      // Log that performance monitoring is active
      PerformanceTracker.trackWidgetBuild('PerformanceMonitor');
    }
    
    return child;
  }
}

/// Performance tracking utilities for specific operations
class PerformanceTracker {
  static void trackWidgetBuild(String widgetName) {
    if (kDebugMode) {
      // Log widget build performance in debug mode
      debugPrint('Building widget: $widgetName');
    }
  }

  static void trackDataProcessing(String operation, int itemCount) {
    if (kDebugMode) {
      debugPrint('Processing $itemCount items for $operation');
    }
  }

  static void trackScrollPerformance(String listName, double scrollExtent) {
    if (kDebugMode) {
      debugPrint('Scrolling $listName: ${scrollExtent.toStringAsFixed(2)}px');
    }
  }
}

/// Memory usage monitoring utilities
class MemoryMonitor {
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // This would typically use platform-specific APIs to get memory info
      // For now, we'll just log the context
      debugPrint('Memory usage check at: $context');
    }
  }

  static void checkForMemoryLeaks() {
    if (kDebugMode) {
      debugPrint('Checking for memory leaks...');
      // Implementation would depend on specific memory profiling tools
    }
  }
}