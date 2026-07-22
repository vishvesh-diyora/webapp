import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/portfolio_content.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

abstract final class PortfolioContentParser {
  static PortfolioParsedContent fromDocument(WebsiteDocument document) {
    final primary = document.blockByContentType(1)?.contentData ?? const {};
    final secondary = document.blockByContentType(2)?.contentData ?? const {};
    final tertiary = document.blockByContentType(3)?.contentData ?? const {};

    if (primary.isEmpty && secondary.isEmpty && tertiary.isEmpty) {
      return PortfolioParsedContent(
        profile: PortfolioProfile(
          name: 'Your Name',
          title: 'Your Title',
          bio: '',
          location: '',
          avatarInitials: 'YN',
          avatarGradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          socialLinks: const [],
        ),
        testimonials: const [],
        highlights: const [],
        projects: const [],
      );
    }

    return PortfolioParsedContent(
      profile: _profile(primary),
      testimonials: _testimonials(secondary),
      highlights: _highlights(secondary),
      projects: _projects(tertiary),
    );
  }

  static PortfolioProfile _profile(Map<String, dynamic> data) {
    final socialRaw = data['socialLinks'] as List? ?? const [];
    return PortfolioProfile(
      name: data['name'] as String? ?? 'Your Name',
      title: data['subtitle'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      location: data['location'] as String? ?? '',
      avatarInitials: _initials(data['name'] as String? ?? 'YN'),
      avatarGradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      avatarImageUrl: _imagePath(data['profileImage'] as String?),
      socialLinks: [
        for (final item in socialRaw)
          if (item is Map)
            PortfolioSocialLink(
              platform: item['platform'] as String? ?? 'Link',
              icon: _iconFor(item['icon'] as String?),
              color: const Color(0xFF6366F1),
            ),
      ],
    );
  }

  static List<PortfolioTestimonial> _testimonials(Map<String, dynamic> data) {
    final raw = data['testimonials'] as List? ?? const [];
    return [
      for (final item in raw)
        if (item is Map)
          PortfolioTestimonial(
            quote: item['quote'] as String? ?? '',
            author: item['author'] as String? ?? '',
            role: item['role'] as String? ?? '',
            rating: (item['rating'] as num?)?.toDouble() ?? 5,
          ),
    ];
  }

  static List<PortfolioHighlight> _highlights(Map<String, dynamic> data) {
    final skills = data['skills'] as List? ?? const [];
    return [
      for (var i = 0; i < skills.length; i++)
        PortfolioHighlight(
          title: skills[i].toString(),
          description: '',
          icon: Icons.star_outline_rounded,
        ),
    ];
  }

  static List<PortfolioProject> _projects(Map<String, dynamic> data) {
    final raw = data['projects'] as List? ?? const [];
    return [
      for (final item in raw)
        if (item is Map)
          PortfolioProject(
            title: item['title'] as String? ?? '',
            category: item['category'] as String? ?? '',
            year: item['year'] as String? ?? '',
            description: item['description'] as String? ?? '',
            gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            icon: Icons.layers_outlined,
          ),
    ];
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'YN';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  static String? _imagePath(String? path) {
    if (path == null || path.isEmpty) return null;
    return path;
  }

  static IconData _iconFor(String? key) => switch (key) {
        'instagram' => Icons.camera_alt_rounded,
        'linkedin' => Icons.work_rounded,
        'github' => Icons.code_rounded,
        'facebook' => Icons.facebook_rounded,
        'twitter' => Icons.alternate_email_rounded,
        'youtube' => Icons.play_circle_fill_rounded,
        _ => Icons.link_rounded,
      };
}

class PortfolioParsedContent {
  const PortfolioParsedContent({
    required this.profile,
    required this.testimonials,
    required this.highlights,
    required this.projects,
  });

  final PortfolioProfile profile;
  final List<PortfolioTestimonial> testimonials;
  final List<PortfolioHighlight> highlights;
  final List<PortfolioProject> projects;
}
