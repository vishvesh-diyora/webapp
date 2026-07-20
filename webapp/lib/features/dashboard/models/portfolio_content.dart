import 'package:flutter/material.dart';

/// Profile + job details block (portfolio contentType 1).
class PortfolioProfile {
  const PortfolioProfile({
    required this.name,
    required this.title,
    required this.bio,
    required this.location,
    required this.avatarInitials,
    required this.avatarGradient,
    required this.socialLinks,
    this.avatarImageUrl,
  });

  final String name;
  final String title;
  final String bio;
  final String location;
  final String avatarInitials;
  final List<Color> avatarGradient;
  final List<PortfolioSocialLink> socialLinks;

  /// When null, a 3D-style memoji avatar is shown instead.
  final String? avatarImageUrl;
}

class PortfolioSocialLink {
  const PortfolioSocialLink({
    required this.platform,
    required this.icon,
    required this.color,
  });

  final String platform;
  final IconData icon;
  final Color color;
}

/// Testimonials + occupation highlights (portfolio contentType 2).
class PortfolioTestimonial {
  const PortfolioTestimonial({
    required this.quote,
    required this.author,
    required this.role,
    required this.rating,
  });

  final String quote;
  final String author;
  final String role;
  final double rating;
}

class PortfolioHighlight {
  const PortfolioHighlight({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

/// Achievements / completed projects (portfolio contentType 3).
class PortfolioProject {
  const PortfolioProject({
    required this.title,
    required this.category,
    required this.year,
    required this.description,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String category;
  final String year;
  final String description;
  final List<Color> gradient;
  final IconData icon;
}

/// Visual theme for a portfolio template design.
class PortfolioTheme {
  const PortfolioTheme({
    required this.heroBackground,
    this.heroGradient,
    required this.heroAccent,
    required this.heroNameColor,
    required this.heroSubtitleColor,
    required this.heroBioColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.sectionAccent,
    required this.socialStyle,
    required this.isDark,
  });

  final Color heroBackground;
  final List<Color>? heroGradient;
  final Color heroAccent;
  final Color heroNameColor;
  final Color heroSubtitleColor;
  final Color heroBioColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color sectionAccent;
  final PortfolioSocialStyle socialStyle;
  final bool isDark;
}

enum PortfolioSocialStyle {
  filled,
  outlined,
  glass,
  minimal,
  bold,
}
