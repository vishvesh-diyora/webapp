import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/portfolio_content.dart';

enum SocialBarVariant {
  outlined,
  filled,
  glass,
  minimal,
  neon,
  brutalist,
  luxury,
  pastel,
}

class PortfolioSocialBar extends StatelessWidget {
  const PortfolioSocialBar({
    super.key,
    required this.links,
    required this.compact,
    required this.variant,
    this.centered = false,
    this.iconColor,
    this.borderColor,
  });

  final List<PortfolioSocialLink> links;
  final bool compact;
  final SocialBarVariant variant;
  final bool centered;
  final Color? iconColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 40.0;
    return Wrap(
      spacing: compact ? 8 : 10,
      runSpacing: compact ? 8 : 10,
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      children: [for (final link in links) _btn(link, size)],
    );
  }

  Widget _btn(PortfolioSocialLink link, double size) {
    final iconSize = compact ? 16.0 : 18.0;
    return switch (variant) {
      SocialBarVariant.outlined => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor ?? Colors.white38),
          ),
          child: Icon(link.icon, size: iconSize, color: iconColor ?? link.color),
        ),
      SocialBarVariant.filled => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: link.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(link.icon, size: iconSize, color: Colors.white),
        ),
      SocialBarVariant.glass => ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(link.icon, size: iconSize, color: link.color),
            ),
          ),
        ),
      SocialBarVariant.minimal => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(link.icon, size: iconSize, color: link.color),
        ),
      SocialBarVariant.neon => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: link.color, width: 1.5),
            boxShadow: [
              BoxShadow(color: link.color.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ),
          child: Icon(link.icon, size: iconSize, color: link.color),
        ),
      SocialBarVariant.brutalist => Container(
          width: size,
          height: size,
          color: Colors.black,
          child: Icon(link.icon, size: iconSize, color: Colors.white),
        ),
      SocialBarVariant.luxury => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Icon(link.icon, size: iconSize, color: const Color(0xFFD4AF37)),
        ),
      SocialBarVariant.pastel => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: link.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(link.icon, size: iconSize, color: link.color),
        ),
    };
  }
}

/// Responsive hero name block used across designs.
class PortfolioNameBlock extends StatelessWidget {
  const PortfolioNameBlock({
    super.key,
    required this.name,
    required this.accentColor,
    required this.nameColor,
    required this.nameSize,
    this.align = TextAlign.start,
  });

  final String name;
  final Color accentColor;
  final Color nameColor;
  final double nameSize;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: align,
      text: TextSpan(
        style: TextStyle(
          fontSize: nameSize,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(text: "I'm ", style: TextStyle(color: accentColor)),
          TextSpan(text: name, style: TextStyle(color: nameColor)),
        ],
      ),
    );
  }
}
