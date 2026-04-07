import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Platform detection helper
class PlatformHelper {
  /// True if running on web
  static bool get isWeb => kIsWeb;

  /// True if running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb && (isPlatformIOS || isPlatformAndroid);

  /// True if running on iOS
  static bool get isPlatformIOS {
    try {
      return !kIsWeb && defaultTargetPlatform.name == 'ios';
    } catch (_) {
      return false;
    }
  }

  /// True if running on Android
  static bool get isPlatformAndroid {
    try {
      return !kIsWeb && defaultTargetPlatform.name == 'android';
    } catch (_) {
      return false;
    }
  }

  /// True if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop =>
      !kIsWeb && (isPlatformWindows || isPlatformMacOS || isPlatformLinux);

  static bool get isPlatformWindows {
    try {
      return !kIsWeb && defaultTargetPlatform.name == 'windows';
    } catch (_) {
      return false;
    }
  }

  static bool get isPlatformMacOS {
    try {
      return !kIsWeb && defaultTargetPlatform.name == 'macos';
    } catch (_) {
      return false;
    }
  }

  static bool get isPlatformLinux {
    try {
      return !kIsWeb && defaultTargetPlatform.name == 'linux';
    } catch (_) {
      return false;
    }
  }

  /// Check if we should use desktop layout on web
  /// This is true when running on web AND the viewport is wide enough (>= 900px)
  static bool isWebDesktop(BuildContext context) {
    if (!isWeb) return false;
    final width = MediaQuery.of(context).size.width;
    return width >= 900;
  }

  /// Check if we should use mobile layout on web
  /// This is true when running on web AND the viewport is narrow (< 900px)
  static bool isWebMobile(BuildContext context) {
    if (!isWeb) return false;
    final width = MediaQuery.of(context).size.width;
    return width < 900;
  }
}
