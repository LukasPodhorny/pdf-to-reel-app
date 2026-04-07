import 'package:flutter/material.dart';
import 'package:pdftoreel/utils/platform_helper.dart';

/// Responsive design breakpoints
class ResponsiveBreakpoints {
  /// Mobile: < 600dp
  static const double mobileMaxWidth = 600;

  /// Tablet: 600dp - 900dp
  static const double tabletMaxWidth = 900;

  /// Desktop: >= 900dp
  static const double desktopMinWidth = 900;
}

/// Enum to define the current screen size category
enum ScreenCategory { mobile, tablet, desktop }

/// Determines screen category based on width
ScreenCategory getScreenCategory(double width) {
  if (width < ResponsiveBreakpoints.mobileMaxWidth) {
    return ScreenCategory.mobile;
  } else if (width < ResponsiveBreakpoints.tabletMaxWidth) {
    return ScreenCategory.tablet;
  } else {
    return ScreenCategory.desktop;
  }
}

/// Responsive layout wrapper that provides different layouts for mobile and desktop
class ResponsiveLayout extends StatefulWidget {
  /// Widget to display on mobile/tablet (your existing mobile screens)
  final Widget mobileWidget;

  /// Optional: Custom widget for desktop (if null, mobile widget is centered in max-width container)
  final Widget? desktopWidget;

  /// Maximum width for mobile layout on larger screens (when no desktopWidget provided)
  final double mobileMaxWidth;

  /// Padding for desktop layout
  final EdgeInsets desktopPadding;

  const ResponsiveLayout({
    required this.mobileWidget,
    this.desktopWidget,
    this.mobileMaxWidth = ResponsiveBreakpoints.mobileMaxWidth,
    this.desktopPadding = const EdgeInsets.symmetric(horizontal: 24.0),
    super.key,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebDesktop = PlatformHelper.isWebDesktop(context);
    final screenCategory = getScreenCategory(screenWidth);

    // On desktop web with a custom desktop widget, show it
    if (isWebDesktop && widget.desktopWidget != null) {
      return widget.desktopWidget!;
    }

    // On mobile web or native mobile/tablet, show mobile widget as-is
    if (screenCategory == ScreenCategory.mobile ||
        screenCategory == ScreenCategory.tablet) {
      return widget.mobileWidget;
    }

    // On native desktop (Windows/Mac/Linux) without desktopWidget, center mobile widget
    if (widget.desktopWidget != null) {
      return widget.desktopWidget!;
    }

    // Default: center mobile widget with max-width constraint
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.mobileMaxWidth),
        child: widget.mobileWidget,
      ),
    );
  }
}

/// Alternative: Simpler constraint-only responsive layout
/// Use this if you just want to prevent mobile screens from stretching on desktop
class ResponsiveConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveConstraint({
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.mobileMaxWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
