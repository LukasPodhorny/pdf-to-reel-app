import 'package:flutter/rendering.dart';

/// Responsive grid delegate that adjusts column count based on screen width
class ResponsiveGridDelegate extends SliverGridDelegate {
  /// Minimum width per item
  final double minItemWidth;

  /// Spacing between items
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  /// Aspect ratio of each item
  final double childAspectRatio;

  /// Maximum columns (for very wide screens)
  final int maxColumns;

  /// Minimum columns (for narrow screens)
  final int minColumns;

  const ResponsiveGridDelegate({
    this.minItemWidth = 180,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 0.6,
    this.maxColumns = 6,
    this.minColumns = 2,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Calculate the number of columns based on available width
    int crossAxisCount = (constraints.crossAxisExtent / minItemWidth).floor();
    crossAxisCount = crossAxisCount.clamp(minColumns, maxColumns);

    // Adjust for desktop web - use more columns on wider screens
    if (constraints.crossAxisExtent >= 1400) {
      crossAxisCount = crossAxisCount.clamp(minColumns, 6);
    } else if (constraints.crossAxisExtent >= 1100) {
      crossAxisCount = crossAxisCount.clamp(minColumns, 5);
    } else if (constraints.crossAxisExtent >= 900) {
      crossAxisCount = crossAxisCount.clamp(minColumns, 4);
    }

    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return oldDelegate is! ResponsiveGridDelegate ||
        oldDelegate.minItemWidth != minItemWidth ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.maxColumns != maxColumns ||
        oldDelegate.minColumns != minColumns;
  }
}

/// Helper function to get responsive cross axis count
int getResponsiveCrossAxisCount(
  double width, {
  int minColumns = 2,
  int maxColumns = 6,
  double minItemWidth = 180,
}) {
  int count = (width / minItemWidth).floor();
  return count.clamp(minColumns, maxColumns);
}
