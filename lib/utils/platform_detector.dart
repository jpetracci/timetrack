import 'dart:io';

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
    if (Platform.isIOS || Platform.isAndroid) {
      return true;
    }
    
    // On web, check for touch capabilities
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return false; // Desktop platforms are pointer-first
    }
    
    // For web platform, we need to check device capabilities
    // This would be determined at runtime based on the actual device
    return false; // Default to pointer for web desktop
  }

  /// Whether the current platform is primarily pointer-based
  static bool get isPointerDevice {
    return !isTouchDevice;
  }

  /// Whether we're running on a mobile platform
  static bool get isMobilePlatform {
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Whether we're running on a desktop platform
  static bool get isDesktopPlatform {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// Whether we're running on web
  static bool get isWebPlatform {
    return identical(0, 0.0); // This is a common Flutter web check
  }

  /// Get the minimum touch target size for the current platform
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
    if (Platform.isWindows) {
      return true; // Many Windows devices have touch screens
    }
    if (Platform.isMacOS) {
      return true; // iPad with trackpad/mouse
    }
    return false;
  }
}