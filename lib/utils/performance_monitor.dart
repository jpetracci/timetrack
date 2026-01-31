import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_performance_monitor_plus/flutter_performance_monitor_plus.dart';

/// Helper function to take last N elements from a list
List<T> _takeLast<T>(List<T> list, int n) {
  if (list.length <= n) {
    return List.from(list);
  }
  return list.sublist(list.length - n);
}

/// Performance monitoring wrapper that activates only in debug mode
/// 
/// This widget tracks performance metrics when running in debug mode.
/// In release mode, it renders children without any overhead.
class PerformanceMonitor extends StatelessWidget {
  const PerformanceMonitor({
    super.key,
    required this.child,
    this.enableAdvancedOverlay = true,
  });

  final Widget child;
  final bool enableAdvancedOverlay;

  @override
  Widget build(BuildContext context) {
    // In debug mode, wrap with advanced performance monitoring
    if (kDebugMode) {
      if (enableAdvancedOverlay) {
        // Wrap with the advanced performance monitor overlay
        return PerformanceMonitorPlus(
          config: const PerformanceMonitorConfig(
            enableFps: true,
            enableFrameTime: true,
            enableRebuildsCount: true,
            enableMemory: true,
            enableNetworkLogging: true,
            overlayPosition: PerformanceOverlayPosition.topRight,
            overlayOpacity: 0.9,
            expandedByDefault: false,
            maxNetworkEntries: 50,
            mode: PerformanceMonitorMode.visible,
          ),
          child: _BasicPerformanceMonitor(child: child),
        );
      } else {
        return _BasicPerformanceMonitor(child: child);
      }
    }
    
    return child;
  }
}

/// Internal widget for basic performance tracking
class _BasicPerformanceMonitor extends StatelessWidget {
  const _BasicPerformanceMonitor({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Log that performance monitoring is active
    PerformanceTracker.trackWidgetBuild('_BasicPerformanceMonitor');
    return child;
  }
}

/// Performance tracking utilities for specific operations
class PerformanceTracker {
  static StreamSubscription<PerformanceMetrics>? _metricsSubscription;

  /// Initialize advanced performance tracking
  static void initializeAdvancedTracking() {
    if (kDebugMode && _metricsSubscription == null) {
      _metricsSubscription = PerformanceMonitorPlus.metricsStream?.listen(
        (PerformanceMetrics metrics) {
          _logAdvancedMetrics(metrics);
        },
      );
    }
  }

  /// Dispose advanced performance tracking
  static void disposeAdvancedTracking() {
    _metricsSubscription?.cancel();
    _metricsSubscription = null;
  }

  /// Log advanced performance metrics
  static void _logAdvancedMetrics(PerformanceMetrics metrics) {
    if (!kDebugMode) return;

    debugPrint('=== Performance Metrics ===');
    debugPrint('FPS: ${metrics.fps.toStringAsFixed(1)}');
    debugPrint('Build Time: ${metrics.averageBuildTimeMs.toStringAsFixed(2)}ms');
    debugPrint('Raster Time: ${metrics.averageRasterTimeMs.toStringAsFixed(2)}ms');
    debugPrint('Rebuilds/sec: ${metrics.rebuildsPerSecond}');
    debugPrint('Jank/sec: ${metrics.jankPerSecond}');
    
    if (metrics.memoryInMB != null) {
      debugPrint('Memory: ${metrics.memoryInMB!.toStringAsFixed(1)}MB');
    }
    
    if (metrics.cpuUsagePercent != null) {
      debugPrint('CPU: ${metrics.cpuUsagePercent!.toStringAsFixed(1)}%');
    }
    
    debugPrint('Hot Reloads: ${metrics.hotReloadCount}');
    debugPrint('Hot Restarts: ${metrics.hotRestartCount}');
    debugPrint('========================');
  }

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

  /// Track custom network requests
  static void trackNetworkRequest({
    required String method,
    required String url,
    required Duration duration,
    int? statusCode,
    Object? error,
  }) {
    if (kDebugMode) {
      PerformanceMonitorPlus.logNetworkRequest(
        method: method,
        url: url,
        duration: duration,
        statusCode: statusCode,
        error: error,
      );
    }
  }
}

/// Memory usage monitoring utilities
class MemoryMonitor {
  static final List<double> _memoryHistory = [];

  /// Log current memory usage with context
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // Get current memory from performance metrics stream
      _getCurrentMemoryUsage().then((memoryMB) {
        if (memoryMB != null) {
          _memoryHistory.add(memoryMB);
          
          // Keep only last 100 entries
          if (_memoryHistory.length > 100) {
            _memoryHistory.removeAt(0);
          }
          
          debugPrint('Memory usage at $context: ${memoryMB.toStringAsFixed(1)}MB');
          
          // Check for memory spikes
          _checkForMemorySpikes(memoryMB);
        }
      });
    }
  }

  /// Check for potential memory leaks by monitoring growth
  static void checkForMemoryLeaks() {
    if (kDebugMode && _memoryHistory.length >= 10) {
      final recent = _takeLast(_memoryHistory, 10);
      final earlier = _takeLast(_memoryHistory.skip(recent.length).toList(), 10);
      
      if (earlier.isNotEmpty) {
        final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
        final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
        
        // If memory increased by more than 20%, warn about potential leak
        if (recentAvg > earlierAvg * 1.2) {
          debugPrint('⚠️ Potential memory leak detected:');
          debugPrint('  Earlier average: ${earlierAvg.toStringAsFixed(1)}MB');
          debugPrint('  Recent average: ${recentAvg.toStringAsFixed(1)}MB');
          debugPrint('  Growth: ${((recentAvg - earlierAvg) / earlierAvg * 100).toStringAsFixed(1)}%');
        }
      }
    }
  }

  /// Get memory usage trends
  static MemoryTrends getMemoryTrends() {
    if (_memoryHistory.length < 2) {
      return MemoryTrends(stable: true, trend: 'insufficient_data');
    }

    final recent = _takeLast(_memoryHistory, 5);
    final earlier = _takeLast(_memoryHistory.skip(recent.length).toList(), 5);
    
    if (earlier.isEmpty) {
      return MemoryTrends(stable: true, trend: 'insufficient_data');
    }

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
    
    final changePercent = ((recentAvg - earlierAvg) / earlierAvg * 100);
    
    if (changePercent.abs() < 5) {
      return MemoryTrends(stable: true, trend: 'stable', changePercent: changePercent);
    } else if (changePercent > 0) {
      return MemoryTrends(stable: false, trend: 'increasing', changePercent: changePercent);
    } else {
      return MemoryTrends(stable: false, trend: 'decreasing', changePercent: changePercent);
    }
  }

  /// Get current memory usage from performance metrics
  static Future<double?> _getCurrentMemoryUsage() async {
    // The performance monitor provides memory data through the stream
    // We'll get the latest value from a completer pattern
    final completer = Completer<double?>();
    
    StreamSubscription<PerformanceMetrics>? subscription;
    subscription = PerformanceMonitorPlus.metricsStream?.listen(
      (metrics) {
        if (metrics.memoryInMB != null) {
          completer.complete(metrics.memoryInMB);
          subscription?.cancel();
        }
      },
    );
    
    // Timeout after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (!completer.isCompleted) {
        completer.complete(null);
        subscription?.cancel();
      }
    });
    
    return completer.future;
  }

  /// Check for memory spikes
  static void _checkForMemorySpikes(double currentMemory) {
    if (_memoryHistory.length >= 2) {
      final previous = _memoryHistory[_memoryHistory.length - 2];
      final increase = currentMemory - previous;
      final increasePercent = (increase / previous) * 100;
      
      if (increasePercent > 50) {
        debugPrint('🚨 Memory spike detected: +${increasePercent.toStringAsFixed(1)}% '
                  '(${previous.toStringAsFixed(1)}MB → ${currentMemory.toStringAsFixed(1)}MB)');
      }
    }
  }
}

/// Memory usage trends information
class MemoryTrends {
  const MemoryTrends({
    required this.stable,
    required this.trend,
    this.changePercent,
  });

  final bool stable;
  final String trend; // 'stable', 'increasing', 'decreasing', 'insufficient_data'
  final double? changePercent;

  @override
  String toString() {
    if (changePercent != null) {
      return 'MemoryTrend($trend, ${changePercent!.toStringAsFixed(1)}%)';
    }
    return 'MemoryTrend($trend)';
  }
}

/// Frame rate monitoring utilities
class FrameRateMonitor {
  static double? _lastFps;
  static final List<double> _fpsHistory = [];
  static StreamSubscription<PerformanceMetrics>? _fpsSubscription;

  /// Initialize frame rate monitoring
  static void initialize() {
    if (kDebugMode && _fpsSubscription == null) {
      _fpsSubscription = PerformanceMonitorPlus.metricsStream?.listen(
        (PerformanceMetrics metrics) {
          _recordFrameRate(metrics.fps);
        },
      );
    }
  }

  /// Dispose frame rate monitoring
  static void dispose() {
    _fpsSubscription?.cancel();
    _fpsSubscription = null;
  }

  /// Record current frame rate
  static void _recordFrameRate(double fps) {
    _lastFps = fps;
    _fpsHistory.add(fps);
    
    // Keep only last 100 entries
    if (_fpsHistory.length > 100) {
      _fpsHistory.removeAt(0);
    }
  }

  /// Get current FPS
  static double? get currentFps => _lastFps;

  /// Get frame rate statistics
  static FrameRateStats getStats() {
    if (_fpsHistory.isEmpty) {
      return FrameRateStats(
        average: 0.0,
        min: 0.0,
        max: 0.0,
        samples: 0,
        isSmooth: false,
      );
    }

    final average = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
    final min = _fpsHistory.reduce((a, b) => a < b ? a : b);
    final max = _fpsHistory.reduce((a, b) => a > b ? a : b);

    // Consider smooth if average >= 55 and min >= 30
    final isSmooth = average >= 55 && min >= 30;

    return FrameRateStats(
      average: average,
      min: min,
      max: max,
      samples: _fpsHistory.length,
      isSmooth: isSmooth,
    );
  }

  /// Log frame rate performance
  static void logFrameRate(String context) {
    if (kDebugMode && _lastFps != null) {
      final stats = getStats();
      debugPrint('Frame rate at $context: ${_lastFps!.toStringAsFixed(1)} FPS '
                '(avg: ${stats.average.toStringAsFixed(1)}, min: ${stats.min.toStringAsFixed(1)})');
      
      if (!stats.isSmooth) {
        debugPrint('⚠️ Frame rate performance issues detected');
      }
    }
  }

  /// Check for frame rate drops
  static void checkForFrameDrops() {
    if (_fpsHistory.length >= 10) {
      final recent = _takeLast(_fpsHistory, 10);
      final avgFps = recent.reduce((a, b) => a + b) / recent.length;
      
      if (avgFps < 30) {
        debugPrint('🚨 Severe frame rate drop detected: ${avgFps.toStringAsFixed(1)} FPS average');
      } else if (avgFps < 45) {
        debugPrint('⚠️ Frame rate drop detected: ${avgFps.toStringAsFixed(1)} FPS average');
      }
    }
  }
}

/// Frame rate statistics
class FrameRateStats {
  const FrameRateStats({
    required this.average,
    required this.min,
    required this.max,
    required this.samples,
    required this.isSmooth,
  });

  final double average;
  final double min;
  final double max;
  final int samples;
  final bool isSmooth;

  @override
  String toString() {
    return 'FrameStats(${average.toStringAsFixed(1)} FPS avg, '
           '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)} range, '
           '$samples samples, smooth: $isSmooth)';
  }
}

/// CPU usage monitoring utilities
class CpuMonitor {
  static double? _lastCpuUsage;
  static final List<double> _cpuHistory = [];
  static StreamSubscription<PerformanceMetrics>? _cpuSubscription;

  /// Initialize CPU monitoring
  static void initialize() {
    if (kDebugMode && _cpuSubscription == null) {
      _cpuSubscription = PerformanceMonitorPlus.metricsStream?.listen(
        (PerformanceMetrics metrics) {
          _recordCpuUsage(metrics.cpuUsagePercent);
        },
      );
    }
  }

  /// Dispose CPU monitoring
  static void dispose() {
    _cpuSubscription?.cancel();
    _cpuSubscription = null;
  }

  /// Record current CPU usage
  static void _recordCpuUsage(double? cpuUsage) {
    if (cpuUsage != null) {
      _lastCpuUsage = cpuUsage;
      _cpuHistory.add(cpuUsage);
      
      // Keep only last 100 entries
      if (_cpuHistory.length > 100) {
        _cpuHistory.removeAt(0);
      }
    }
  }

  /// Get current CPU usage
  static double? get currentUsage => _lastCpuUsage;

  /// Get CPU usage statistics
  static CpuStats getStats() {
    if (_cpuHistory.isEmpty) {
      return CpuStats(
        average: 0.0,
        max: 0.0,
        samples: 0,
        isHighUsage: false,
      );
    }

    final average = _cpuHistory.reduce((a, b) => a + b) / _cpuHistory.length;
    final max = _cpuHistory.reduce((a, b) => a > b ? a : b);

    // Consider high usage if average > 70%
    final isHighUsage = average > 70.0;

    return CpuStats(
      average: average,
      max: max,
      samples: _cpuHistory.length,
      isHighUsage: isHighUsage,
    );
  }

  /// Log CPU usage
  static void logCpuUsage(String context) {
    if (kDebugMode && _lastCpuUsage != null) {
      final stats = getStats();
      debugPrint('CPU usage at $context: ${_lastCpuUsage!.toStringAsFixed(1)}% '
                '(avg: ${stats.average.toStringAsFixed(1)}%, max: ${stats.max.toStringAsFixed(1)}%)');
      
      if (stats.isHighUsage) {
        debugPrint('⚠️ High CPU usage detected');
      }
    }
  }

  /// Check for CPU spikes
  static void checkForCpuSpikes() {
    if (_cpuHistory.length >= 10) {
      final recent = _takeLast(_cpuHistory, 10);
      final avgCpu = recent.reduce((a, b) => a + b) / recent.length;
      
      if (avgCpu > 90) {
        debugPrint('🚨 Severe CPU usage spike: ${avgCpu.toStringAsFixed(1)}% average');
      } else if (avgCpu > 80) {
        debugPrint('⚠️ High CPU usage spike: ${avgCpu.toStringAsFixed(1)}% average');
      }
    }
  }

  /// Get CPU performance level
  static CpuPerformanceLevel getPerformanceLevel() {
    if (_lastCpuUsage == null) {
      return CpuPerformanceLevel.unknown;
    }

    final usage = _lastCpuUsage!;
    if (usage <= 30) {
      return CpuPerformanceLevel.low;
    } else if (usage <= 60) {
      return CpuPerformanceLevel.moderate;
    } else if (usage <= 80) {
      return CpuPerformanceLevel.high;
    } else {
      return CpuPerformanceLevel.critical;
    }
  }
}

/// CPU usage statistics
class CpuStats {
  const CpuStats({
    required this.average,
    required this.max,
    required this.samples,
    required this.isHighUsage,
  });

  final double average;
  final double max;
  final int samples;
  final bool isHighUsage;

  @override
  String toString() {
    return 'CpuStats(${average.toStringAsFixed(1)}% avg, '
           '${max.toStringAsFixed(1)}% max, $samples samples, high: $isHighUsage)';
  }
}

/// CPU performance levels
enum CpuPerformanceLevel {
  low,
  moderate,
  high,
  critical,
  unknown,
}