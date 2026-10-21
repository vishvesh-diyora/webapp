import 'package:flutter/material.dart';
import 'package:webapp/features/templates/preview/layout_theme.dart';

/// Search affordance shared by ecommerce and restaurant catalog previews.
abstract final class CatalogSearchIcon {
  static const IconData data = Icons.manage_search_rounded;

  static Widget navButton({
    required LayoutTheme theme,
    required bool compact,
    required VoidCallback onPressed,
  }) {
    final side = compact ? 40.0 : 44.0;
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Search products',
      style: IconButton.styleFrom(
        backgroundColor: theme.primary.withValues(alpha: 0.1),
        foregroundColor: theme.primary,
        disabledForegroundColor: theme.text.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        minimumSize: Size(side, side),
        maximumSize: Size(side, side),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(data, size: compact ? 22 : 24),
    );
  }

  static Widget fieldPrefix(LayoutTheme theme, {bool compact = false}) {
    return Icon(
      data,
      size: compact ? 22 : 24,
      color: theme.primary.withValues(alpha: 0.85),
    );
  }
}
