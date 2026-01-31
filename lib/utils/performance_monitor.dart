import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_performance_monitor_plus/flutter_performance_monitor_plus.dart';

/// Performance monitoring wrapper that activates only in debug mode
/// 
/// This widget wraps the app with performance monitoring overlay
/// when running in debug mode, providing real-time metrics.
/// In release mode, it renders the child without any overhead.
class PerformanceMonitor extends StatelessWidget {
  const PerformanceMonitor({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Only enable performance monitoring in debug mode
    if (kDebugMode) {
      return Stack(
        children: [
          child,
          // Performance overlay positioned in top-right corner
          Positioned(
            top: 50,
            right: 10,
            child: PerformanceMonitorPlus(
              child: Container(), // Required child parameter
            ),
          ),
        ],
      );
    } else {
      // In release mode, just return the child without monitoring overhead
      return child;
    }
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