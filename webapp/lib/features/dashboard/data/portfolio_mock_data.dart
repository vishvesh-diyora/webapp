import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/portfolio_content.dart';

/// Static portfolio content shared by all template designs.
abstract final class PortfolioMockData {
  static const profile = PortfolioProfile(
    name: 'Maya Chen',
    title: 'Digital Artist & Creative Director',
    bio:
        'A creative professional inspired by art, travel, and innovation to build unforgettable visual experiences.',
    location: 'San Francisco, CA',
    avatarInitials: 'MC',
    avatarGradient: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    avatarImageUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&h=800&fit=crop&q=80',
    socialLinks: [
      PortfolioSocialLink(
        platform: 'Instagram',
        icon: Icons.camera_alt_rounded,
        color: Color(0xFFE1306C),
      ),
      PortfolioSocialLink(
        platform: 'Facebook',
        icon: Icons.facebook_rounded,
        color: Color(0xFF1877F2),
      ),
      PortfolioSocialLink(
        platform: 'Twitter',
        icon: Icons.alternate_email_rounded,
        color: Color(0xFF1DA1F2),
      ),
      PortfolioSocialLink(
        platform: 'YouTube',
        icon: Icons.play_circle_fill_rounded,
        color: Color(0xFFFF0000),
      ),
      PortfolioSocialLink(
        platform: 'LinkedIn',
        icon: Icons.work_rounded,
        color: Color(0xFF0A66C2),
      ),
      PortfolioSocialLink(
        platform: 'GitHub',
        icon: Icons.code_rounded,
        color: Color(0xFF24292F),
      ),
    ],
  );

  static const testimonials = [
    PortfolioTestimonial(
      quote:
          'Maya transformed our brand identity with artwork that feels alive. Every deliverable exceeded expectations.',
      author: 'Sarah Okonkwo',
      role: 'CMO, Lumina Studios',
      rating: 5,
    ),
    PortfolioTestimonial(
      quote:
          'Her creative direction on our game launch campaign doubled engagement across all channels.',
      author: 'James Rivera',
      role: 'Lead Producer, PixelForge',
      rating: 5,
    ),
    PortfolioTestimonial(
      quote:
          'Professional, visionary, and incredibly detail-oriented. A true artist who understands business.',
      author: 'Dr. Elena Vasquez',
      role: 'Gallery Director, Modern Art Co.',
      rating: 4.5,
    ),
  ];

  static const highlights = [
    PortfolioHighlight(
      title: 'Brand Identity',
      description: 'Logo systems, style guides, and visual language for 40+ brands.',
      icon: Icons.auto_awesome_outlined,
    ),
    PortfolioHighlight(
      title: 'Game Art & UI',
      description: 'Character design, environments, and interface art for indie & AAA titles.',
      icon: Icons.sports_esports_outlined,
    ),
    PortfolioHighlight(
      title: 'Illustration',
      description: 'Editorial, book covers, and gallery-ready fine art pieces.',
      icon: Icons.brush_outlined,
    ),
    PortfolioHighlight(
      title: 'Motion Design',
      description: 'Animated logos, social content, and interactive experiences.',
      icon: Icons.animation_outlined,
    ),
  ];

  static const projects = [
    PortfolioProject(
      title: 'Neon Dreams Collection',
      category: 'Digital Art',
      year: '2025',
      description: 'A 12-piece series exploring cyberpunk aesthetics.',
      gradient: [Color(0xFF7C3AED), Color(0xFF2563EB)],
      icon: Icons.nightlight_round,
    ),
    PortfolioProject(
      title: 'EcoVerse Rebrand',
      category: 'Brand Identity',
      year: '2024',
      description: 'Full rebrand for a sustainable tech startup.',
      gradient: [Color(0xFF059669), Color(0xFF0D9488)],
      icon: Icons.eco_outlined,
    ),
    PortfolioProject(
      title: 'Starfall RPG',
      category: 'Game Art',
      year: '2024',
      description: 'Character concepts and world-building for an indie RPG.',
      gradient: [Color(0xFFDC2626), Color(0xFF9333EA)],
      icon: Icons.videogame_asset_outlined,
    ),
    PortfolioProject(
      title: 'Pulse Festival',
      category: 'Event Design',
      year: '2023',
      description: 'Visual identity and stage art for a music festival.',
      gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      icon: Icons.music_note_outlined,
    ),
  ];
}

/// Theme presets for each portfolio template design.
abstract final class PortfolioThemes {
  static const creativePulse = PortfolioTheme(
    heroBackground: Color(0xFF0A0A0F),
    heroGradient: [Color(0xFF1A1033), Color(0xFF0A0A0F)],
    heroAccent: Color(0xFF8B5CF6),
    heroNameColor: Colors.white,
    heroSubtitleColor: Color(0xFF8B5CF6),
    heroBioColor: Color(0xFF94A3B8),
    surfaceColor: Color(0xFFFAFAFA),
    cardColor: Colors.white,
    borderColor: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    sectionAccent: Color(0xFF8B5CF6),
    socialStyle: PortfolioSocialStyle.outlined,
    isDark: false,
  );

  static const minimalSlate = PortfolioTheme(
    heroBackground: Colors.white,
    heroAccent: Color(0xFF334155),
    heroNameColor: Color(0xFF0F172A),
    heroSubtitleColor: Color(0xFF64748B),
    heroBioColor: Color(0xFF94A3B8),
    surfaceColor: Color(0xFFF8FAFC),
    cardColor: Colors.white,
    borderColor: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    sectionAccent: Color(0xFF334155),
    socialStyle: PortfolioSocialStyle.minimal,
    isDark: false,
  );

  static const noirStudio = PortfolioTheme(
    heroBackground: Color(0xFF000000),
    heroGradient: [Color(0xFF1A1A1A), Color(0xFF000000)],
    heroAccent: Color(0xFFD4AF37),
    heroNameColor: Colors.white,
    heroSubtitleColor: Color(0xFFD4AF37),
    heroBioColor: Color(0xFF9CA3AF),
    surfaceColor: Color(0xFF0F0F0F),
    cardColor: Color(0xFF1A1A1A),
    borderColor: Color(0xFF2D2D2D),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF9CA3AF),
    sectionAccent: Color(0xFFD4AF37),
    socialStyle: PortfolioSocialStyle.outlined,
    isDark: true,
  );

  static const editorialBold = PortfolioTheme(
    heroBackground: Color(0xFF0F172A),
    heroAccent: Color(0xFFDC2626),
    heroNameColor: Colors.white,
    heroSubtitleColor: Color(0xFFFBBF24),
    heroBioColor: Color(0xFFCBD5E1),
    surfaceColor: Color(0xFFFAFAFA),
    cardColor: Colors.white,
    borderColor: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    sectionAccent: Color(0xFFDC2626),
    socialStyle: PortfolioSocialStyle.bold,
    isDark: false,
  );

  static const auroraGlass = PortfolioTheme(
    heroBackground: Color(0xFF0F172A),
    heroGradient: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF0F172A)],
    heroAccent: Color(0xFF06B6D4),
    heroNameColor: Colors.white,
    heroSubtitleColor: Color(0xFF06B6D4),
    heroBioColor: Color(0xFF94A3B8),
    surfaceColor: Colors.transparent,
    cardColor: Color(0x1AFFFFFF),
    borderColor: Color(0x33FFFFFF),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF94A3B8),
    sectionAccent: Color(0xFF06B6D4),
    socialStyle: PortfolioSocialStyle.glass,
    isDark: true,
  );

  static PortfolioTheme forTemplateType(int templateType) => switch (templateType) {
        1 => creativePulse,
        2 => minimalSlate,
        3 => noirStudio,
        4 => editorialBold,
        5 => auroraGlass,
        _ => creativePulse,
      };
}
