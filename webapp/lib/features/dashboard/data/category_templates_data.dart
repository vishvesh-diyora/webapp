import 'package:flutter/material.dart';
import 'package:webapp/features/dashboard/models/category_template.dart';

/// Visual accent metadata for each portfolio template design.
class PortfolioTemplateStyle {
  const PortfolioTemplateStyle({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.previewGradient,
    required this.icon,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final List<Color> previewGradient;
  final IconData icon;
}

/// Static local templates for all categories (not Supabase — code only).
abstract final class CategoryTemplatesData {
  static const List<CategoryTemplate> all = [
    ecommerce,
    ...portfolioTemplates,
    gift,
    custom,
  ];

  static const CategoryTemplate ecommerce = CategoryTemplate(
    type: CategoryType.ecommerce,
    templateType: 1,
    name: 'E-commerce Store',
    subname: 'Sell products online',
    description:
        'Launch a modern online store with banners, product categories, and featured products.',
    data: [
      CategoryContentBlock(seqId: 1, contentType: ContentType.banners),
      CategoryContentBlock(seqId: 2, contentType: ContentType.categories),
      CategoryContentBlock(seqId: 3, contentType: ContentType.products),
    ],
  );

  static const List<CategoryTemplate> portfolioTemplates = [
    portfolioSplitMonochrome,
    portfolioDarkDev,
    portfolioSwissMinimal,
    portfolioNoirCinema,
    portfolioEditorialMagazine,
    portfolioAuroraGlass,
    portfolioNeonCyber,
    portfolioPastelDream,
    portfolioBrutalist,
    portfolioNatureZen,
    portfolioLuxuryGold,
  ];

  static const _portfolioData = [
    CategoryContentBlock(seqId: 1, contentType: ContentType.banners),
    CategoryContentBlock(seqId: 2, contentType: ContentType.categories),
    CategoryContentBlock(seqId: 3, contentType: ContentType.products),
  ];

  static const CategoryTemplate portfolioDarkDev = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 1,
    name: 'Dark Dev',
    subname: 'Developer portfolio',
    description: 'Black hero, purple accent, profile photo beside name — like a premium dev site.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioSwissMinimal = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 2,
    name: 'Swiss Minimal',
    subname: 'Typography-first',
    description: 'Ultra-clean whitespace, thin rules, numbered testimonials.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioNoirCinema = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 3,
    name: 'Noir Cinema',
    subname: 'Film & photo',
    description: 'Cinematic black with gold frames and widescreen project banners.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioEditorialMagazine = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 4,
    name: 'Editorial Magazine',
    subname: 'Bold editorial',
    description: 'Red/yellow split blocks with profile photo and pull quotes.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioAuroraGlass = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 5,
    name: 'Aurora Glass',
    subname: 'Glassmorphism',
    description: 'Frosted glass cards on aurora gradients with blur animations.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioNeonCyber = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 6,
    name: 'Neon Cyber',
    subname: 'Cyberpunk grid',
    description: 'Neon borders, terminal typography, glitch entrance animations.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioPastelDream = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 7,
    name: 'Pastel Dream',
    subname: 'Soft & friendly',
    description: 'Pastel bubbles, bento grid, bounce animations.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioBrutalist = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 8,
    name: 'Brutalist',
    subname: 'Raw & bold',
    description: 'Harsh contrast blocks, zero radius, snap animations.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioNatureZen = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 9,
    name: 'Nature Zen',
    subname: 'Organic calm',
    description: 'Sage greens, curved hero, vertical timeline projects.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioLuxuryGold = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 10,
    name: 'Luxury Gold',
    subname: 'Premium elegance',
    description: 'Marble tones, gold accents, refined fade animations.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolioSplitMonochrome = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 11,
    name: 'Split Monochrome',
    subname: 'Editorial B&W',
    description: 'Square portrait split-screen with gray editorial panel.',
    data: _portfolioData,
  );

  static const CategoryTemplate portfolio = portfolioSplitMonochrome;
  static const CategoryTemplate portfolioCreativePulse = portfolioDarkDev;
  static const CategoryTemplate portfolioMinimalSlate = portfolioSwissMinimal;
  static const CategoryTemplate portfolioNoirStudio = portfolioNoirCinema;
  static const CategoryTemplate portfolioEditorialBold = portfolioEditorialMagazine;

  static const CategoryTemplate gift = CategoryTemplate(
    type: CategoryType.gift,
    templateType: 1,
    name: 'Gift Experience',
    subname: 'Share something special',
    description:
        'Build a gift page with hero banners, gift categories, and curated picks.',
    data: [
      CategoryContentBlock(seqId: 1, contentType: ContentType.banners),
      CategoryContentBlock(seqId: 2, contentType: ContentType.categories),
      CategoryContentBlock(seqId: 3, contentType: ContentType.products),
    ],
  );

  static const CategoryTemplate custom = CategoryTemplate(
    type: CategoryType.custom,
    templateType: 1,
    name: 'Custom Build',
    subname: 'Design your own layout',
    description:
        'Start from scratch and arrange banners, sections, and content blocks your way.',
    data: [
      CategoryContentBlock(seqId: 1, contentType: ContentType.banners),
      CategoryContentBlock(seqId: 2, contentType: ContentType.categories),
      CategoryContentBlock(seqId: 3, contentType: ContentType.products),
    ],
  );

  static const Map<int, PortfolioTemplateStyle> portfolioStyles = {
    1: PortfolioTemplateStyle(
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFF000000),
      accent: Color(0xFF8B5CF6),
      previewGradient: [Color(0xFF000000), Color(0xFF1A1033)],
      icon: Icons.terminal_rounded,
    ),
    2: PortfolioTemplateStyle(
      primary: Color(0xFF334155),
      secondary: Color(0xFFF8FAFC),
      accent: Color(0xFF0F172A),
      previewGradient: [Color(0xFFFFFFFF), Color(0xFFE2E8F0)],
      icon: Icons.horizontal_rule_rounded,
    ),
    3: PortfolioTemplateStyle(
      primary: Color(0xFF000000),
      secondary: Color(0xFF1A1A1A),
      accent: Color(0xFFD4AF37),
      previewGradient: [Color(0xFF000000), Color(0xFF2D2D2D)],
      icon: Icons.movie_filter_outlined,
    ),
    4: PortfolioTemplateStyle(
      primary: Color(0xFFDC2626),
      secondary: Color(0xFF0F172A),
      accent: Color(0xFFFBBF24),
      previewGradient: [Color(0xFFDC2626), Color(0xFF0F172A)],
      icon: Icons.format_quote_rounded,
    ),
    5: PortfolioTemplateStyle(
      primary: Color(0xFF06B6D4),
      secondary: Color(0xFF8B5CF6),
      accent: Color(0xFFEC4899),
      previewGradient: [Color(0xFF06B6D4), Color(0xFF8B5CF6), Color(0xFFEC4899)],
      icon: Icons.blur_on_rounded,
    ),
    6: PortfolioTemplateStyle(
      primary: Color(0xFF00F5FF),
      secondary: Color(0xFF050510),
      accent: Color(0xFFFF006E),
      previewGradient: [Color(0xFF050510), Color(0xFF1A0A2E)],
      icon: Icons.grid_4x4_rounded,
    ),
    7: PortfolioTemplateStyle(
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFFDF4FF),
      accent: Color(0xFF831843),
      previewGradient: [Color(0xFFFFF1F2), Color(0xFFFDF4FF)],
      icon: Icons.cloud_rounded,
    ),
    8: PortfolioTemplateStyle(
      primary: Color(0xFF000000),
      secondary: Color(0xFFFFE500),
      accent: Color(0xFF000000),
      previewGradient: [Color(0xFFF5F5F0), Color(0xFF000000)],
      icon: Icons.crop_square_rounded,
    ),
    9: PortfolioTemplateStyle(
      primary: Color(0xFF4A7C59),
      secondary: Color(0xFFF7F3EB),
      accent: Color(0xFF2D4A3E),
      previewGradient: [Color(0xFFF7F3EB), Color(0xFF4A7C59)],
      icon: Icons.eco_outlined,
    ),
    10: PortfolioTemplateStyle(
      primary: Color(0xFFD4AF37),
      secondary: Color(0xFFFAF8F5),
      accent: Color(0xFF1C1917),
      previewGradient: [Color(0xFFFAF8F5), Color(0xFFD4AF37)],
      icon: Icons.diamond_outlined,
    ),
    11: PortfolioTemplateStyle(
      primary: Color(0xFF3D3D3D),
      secondary: Color(0xFF2A2A2A),
      accent: Color(0xFFFFFFFF),
      previewGradient: [Color(0xFF1F1F1F), Color(0xFF3D3D3D)],
      icon: Icons.view_column_outlined,
    ),
  };

  static CategoryTemplate? byType(int type) {
    if (type == CategoryType.portfolio) return portfolioSplitMonochrome;
    for (final template in all) {
      if (template.type == type) return template;
    }
    return null;
  }

  static List<CategoryTemplate> byCategoryType(int type) {
    if (type == CategoryType.portfolio) return portfolioTemplates;
    final single = byType(type);
    return single == null ? [] : [single];
  }

  static CategoryTemplate? byTypeAndTemplateType(int type, int templateType) {
    for (final template in byCategoryType(type)) {
      if (template.templateType == templateType) return template;
    }
    return null;
  }

  static PortfolioTemplateStyle styleFor(CategoryTemplate template) {
    return portfolioStyles[template.templateType] ?? portfolioStyles[1]!;
  }
}
