import 'package:flutter/material.dart';

class LayoutTheme {
  const LayoutTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.layout,
    required this.radius,
    required this.fontScale,
    required this.spacing,
    required this.heroStyle,
    required this.cardStyle,
    required this.navStyle,
    required this.footerStyle,
    required this.animation,
    required this.variant,
    required this.secondaryLayout,
    required this.tertiaryLayout,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final String layout;
  final double radius;
  final double fontScale;
  final double spacing;
  final String heroStyle;
  final String cardStyle;
  final String navStyle;
  final String footerStyle;
  final String animation;
  final int variant;
  final String secondaryLayout;
  final String tertiaryLayout;

  factory LayoutTheme.fromContent(Map<String, dynamic>? data) {
    final theme = data?['theme'] as Map<String, dynamic>? ?? const {};
    return LayoutTheme(
      primary: _hex(theme['primary'], const Color(0xFF6366F1)),
      secondary: _hex(theme['secondary'], const Color(0xFF0F172A)),
      accent: _hex(theme['accent'], const Color(0xFF8B5CF6)),
      background: _hex(theme['background'], Colors.white),
      surface: _hex(theme['surface'], const Color(0xFFF8FAFC)),
      text: _hex(theme['text'], const Color(0xFF0F172A)),
      layout: theme['layout'] as String? ?? 'split',
      radius: (theme['radius'] as num?)?.toDouble() ?? 12,
      fontScale: (theme['fontScale'] as num?)?.toDouble() ?? 1,
      spacing: (theme['spacing'] as num?)?.toDouble() ?? 16,
      heroStyle: theme['heroStyle'] as String? ?? 'left',
      cardStyle: theme['cardStyle'] as String? ?? 'elevated',
      navStyle: theme['navStyle'] as String? ?? 'top',
      footerStyle: theme['footerStyle'] as String? ?? 'minimal',
      animation: theme['animation'] as String? ?? 'fadeUp',
      variant: (theme['variant'] as num?)?.toInt() ?? 1,
      secondaryLayout: theme['secondaryLayout'] as String? ?? 'cards',
      tertiaryLayout: theme['tertiaryLayout'] as String? ?? 'grid',
    );
  }

  static Color _hex(dynamic value, Color fallback) {
    if (value is! String || value.isEmpty) return fallback;
    final hex = value.replaceFirst('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    return fallback;
  }

  TextStyle heading(bool compact, {double size = 24}) => TextStyle(
        color: text,
        fontWeight: FontWeight.w800,
        fontSize: (compact ? size * 0.85 : size) * fontScale,
        height: 1.1,
      );

  TextStyle body(bool compact, {double size = 13}) => TextStyle(
        color: text.withValues(alpha: 0.75),
        fontSize: (compact ? size * 0.9 : size) * fontScale,
        height: 1.5,
      );

  EdgeInsets pad(bool compact) =>
      EdgeInsets.all(compact ? spacing * 0.75 : spacing);

  BoxDecoration cardDecoration() => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: cardStyle == 'bordered' || cardStyle == 'line'
            ? Border.all(color: text.withValues(alpha: 0.12))
            : null,
        boxShadow: cardStyle == 'elevated' || cardStyle == 'shadow'
            ? [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      );
}
