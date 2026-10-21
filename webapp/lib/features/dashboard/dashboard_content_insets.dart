import 'package:flutter/material.dart';
import 'package:webapp/core/constants/app_constants.dart';

/// Horizontal layout math shared by tab pages and the bottom nav bar.
abstract final class DashboardContentInsets {
  static double contentMaxWidth(double screenWidth) {
    return screenWidth > AppConstants.maxDashboardWidth
        ? AppConstants.maxDashboardWidth
        : screenWidth;
  }

  /// Inset from the physical screen edge to the centered dashboard column.
  static double columnInset(double screenWidth) {
    return (screenWidth - contentMaxWidth(screenWidth)) / 2;
  }

  /// Matches [HomeConfiguratorTab] category rows (e.g. Gift Reveal): centered
  /// column + [SafeArea] horizontal padding + [dashboardHorizontalGutter].
  static EdgeInsets pageHorizontal(BuildContext context) {
    final media = MediaQuery.of(context);
    final column = columnInset(media.size.width);
    final gutter = AppConstants.dashboardHorizontalGutter;
    return EdgeInsets.only(
      left: column + media.padding.left + gutter,
      right: column + media.padding.right + gutter,
    );
  }
}
