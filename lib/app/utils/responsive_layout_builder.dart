import 'package:flutter/material.dart';

/// A responsive layout widget that selects the appropriate child
/// based on the available width constraints.
///
/// Uses [LayoutBuilder] to respond to the actual available space
/// (not the full window size), which is important when the widget
/// is nested inside a layout that already consumes space (e.g.,
/// a NavigationDrawer sidebar).
///
/// Usage:
/// ```dart
/// ResponsiveLayoutBuilder(
///   desktop: DesktopView(),
///   mobile: MobileView(),
///   // tablet is optional — falls back to desktop if not provided
/// )
/// ```
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.desktop,
    this.tablet,
    this.mobile,
  });

  /// The layout to display on desktop-sized screens (width >= 840).
  final Widget desktop;

  /// The layout to display on tablet-sized screens (600 <= width < 840).
  /// Falls back to [desktop] if not provided.
  final Widget? tablet;

  /// The layout to display on mobile-sized screens (width < 600).
  /// Falls back to [tablet] ?? [desktop] if not provided.
  final Widget? mobile;

  /// Material 3 compact breakpoint (mobile).
  static const double compactBreakpoint = 600;

  /// Material 3 expanded breakpoint (desktop).
  static const double expandedBreakpoint = 840;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < compactBreakpoint) {
          return mobile ?? tablet ?? desktop;
        } else if (constraints.maxWidth < expandedBreakpoint) {
          return tablet ?? desktop;
        }
        return desktop;
      },
    );
  }
}
