import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform detection utilities for touch vs pointer input methods
class PlatformDetector {
  PlatformDetector._();

  /// Initialize platform detection (call from app wrapper if needed)
  static void initialize() {
    // Pre-computation if needed
  }

  /// Whether the current platform is primarily touch-based
  static bool get isTouchDevice {
    // iOS and Android are touch-first platforms
    if (kIsWeb) {
      // On web, default to pointer unless we detect touch capabilities
      return false; // Could be enhanced with touch detection if needed
    }
    
    if (Platform.isIOS || Platform.isAndroid) {
      return true;
    }
    
    // Desktop platforms are pointer-first
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return false;
    }
    
    // Fallback to pointer
    return false;
  }

  /// Whether the current platform is primarily pointer-based
  static bool get isPointerDevice {
    return !isTouchDevice;
  }

  /// Whether we're running on a mobile platform
  static bool get isMobilePlatform {
    if (kIsWeb) {
      return false; // Web is not considered mobile
    }
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Whether we're running on a desktop platform
  static bool get isDesktopPlatform {
    if (kIsWeb) {
      return false; // Web is not considered desktop
    }
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// Whether we're running on web
  static bool get isWebPlatform {
    return kIsWeb;
  }

  /// Get the minimum touch target size for current platform
  static double get minimumTouchTarget {
    if (isTouchDevice) {
      // Material Design recommends 48dp minimum
      return 48.0;
    }
    // Desktop platforms can use smaller targets
    return 32.0;
  }

  /// Check if the device likely has both touch and pointer capabilities
  static bool get hasHybridInput {
    // Windows touchscreens, iPad with mouse/trackpad, etc.
    if (!kIsWeb && Platform.isWindows) {
      return true; // Many Windows devices have touch screens
    }
    if (!kIsWeb && Platform.isMacOS) {
      return true; // iPad with trackpad/mouse
    }
    return false;
  }
}