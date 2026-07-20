import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';
import 'package:webapp/features/dashboard/widgets/device_preview_insets.dart';

/// Screen fill + device chrome spacing for portfolio template previews.
class PreviewScreenBackground {
  const PreviewScreenBackground({
    this.color,
    this.decoration,
    this.isDark = false,
  });

  final Color? color;
  final BoxDecoration? decoration;
  final bool isDark;

  static PreviewScreenBackground forTemplate(
    CategoryTemplate template, {
    bool mobileProfileLayout = false,
  }) {
    if (template.type != CategoryType.portfolio) {
      return const PreviewScreenBackground(color: Color(0xFFF8FAFC));
    }

    return switch (template.templateType) {
      1 => const PreviewScreenBackground(color: Color(0xFF000000), isDark: true),
      2 => const PreviewScreenBackground(color: Colors.white),
      3 => const PreviewScreenBackground(color: Color(0xFF000000), isDark: true),
      4 => const PreviewScreenBackground(color: Colors.white),
      5 => PreviewScreenBackground(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          isDark: true,
        ),
      6 => const PreviewScreenBackground(color: Color(0xFF050510), isDark: true),
      7 => PreviewScreenBackground(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF1F2), Color(0xFFFDF4FF), Color(0xFFEFF6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      8 => const PreviewScreenBackground(color: Color(0xFFF5F5F0)),
      9 => const PreviewScreenBackground(color: Color(0xFFF7F3EB)),
      10 => PreviewScreenBackground(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFAF8F5), Color(0xFFF0EBE3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      11 => const PreviewScreenBackground(color: Color(0xFF2A2A2A), isDark: true),
      _ => const PreviewScreenBackground(color: Color(0xFFF8FAFC)),
    };
  }

  /// Top inset when [mobileProfileLayout] is true (matches [DevicePreviewInsets.iphoneTop]).
  static double mobileTopInset({required bool mobileProfileLayout, bool compact = false}) {
    if (!mobileProfileLayout) return 0;
    return DevicePreviewInsets.iphoneTop;
  }

  static double mobileBottomInset({required bool mobileProfileLayout}) {
    if (!mobileProfileLayout) return 0;
    return DevicePreviewInsets.iphoneBottom;
  }
}
