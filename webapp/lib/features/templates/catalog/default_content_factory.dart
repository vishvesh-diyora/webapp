import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Builds default [contentData] maps per category and content type.
abstract final class DefaultContentFactory {
  static List<WebsiteContentBlock> blocksForCategory(int type, int templateType) {
    return [
      WebsiteContentBlock(
        seqId: 1,
        contentType: ContentType.primary,
        contentData: primaryFor(type, templateType),
      ),
      WebsiteContentBlock(
        seqId: 2,
        contentType: ContentType.secondary,
        contentData: secondaryFor(type, templateType),
      ),
      WebsiteContentBlock(
        seqId: 3,
        contentType: ContentType.tertiary,
        contentData: tertiaryFor(type, templateType),
      ),
    ];
  }

  static Map<String, dynamic> primaryFor(int type, int templateType) =>
      switch (type) {
        CategoryType.portfolio => _portfolioPrimary(templateType),
        CategoryType.businessProfile => _businessPrimary(templateType),
        CategoryType.giftReveal => _giftPrimary(templateType),
        CategoryType.restaurantMenu => _restaurantPrimary(templateType),
        CategoryType.ecommerce => _ecommercePrimary(templateType),
        _ => const {},
      };

  static Map<String, dynamic> secondaryFor(int type, int templateType) =>
      switch (type) {
        CategoryType.portfolio => _portfolioSecondary(templateType),
        CategoryType.businessProfile => _businessSecondary(templateType),
        CategoryType.giftReveal => _giftSecondary(templateType),
        CategoryType.restaurantMenu => _restaurantSecondary(templateType),
        CategoryType.ecommerce => _ecommerceSecondary(templateType),
        _ => const {},
      };

  static Map<String, dynamic> tertiaryFor(int type, int templateType) =>
      switch (type) {
        CategoryType.portfolio => _portfolioTertiary(templateType),
        CategoryType.businessProfile => _businessTertiary(templateType),
        CategoryType.giftReveal => _giftTertiary(templateType),
        CategoryType.restaurantMenu => _restaurantTertiary(templateType),
        CategoryType.ecommerce => _ecommerceTertiary(templateType),
        _ => const {},
      };

  static Map<String, dynamic> _portfolioPrimary(int variant) => {
        'profileImage': 'assets/images/profile.jpg',
        'name': 'Maya Chen',
        'subtitle': 'Digital Artist & Creative Director',
        'bio':
            'A creative professional inspired by art, travel, and innovation to build unforgettable visual experiences.',
        'location': 'San Francisco, CA',
        'resumeUrl': 'assets/files/resume.pdf',
        'socialLinks': [
          {'platform': 'Instagram', 'url': 'https://instagram.com', 'icon': 'instagram'},
          {'platform': 'LinkedIn', 'url': 'https://linkedin.com', 'icon': 'linkedin'},
          {'platform': 'GitHub', 'url': 'https://github.com', 'icon': 'github'},
        ],
        'buttons': [
          {'label': 'View Work', 'url': '#projects', 'style': 'primary'},
          {'label': 'Contact', 'url': '#contact', 'style': 'outline'},
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _portfolioSecondary(int variant) => {
        'about':
            'I craft visual stories for brands, games, and galleries — blending illustration, motion, and strategy.',
        'experience': [
          {
            'role': 'Creative Director',
            'company': 'Lumina Studios',
            'period': '2021 — Present',
            'description': 'Lead brand and campaign creative for global clients.',
          },
          {
            'role': 'Senior Illustrator',
            'company': 'PixelForge Games',
            'period': '2017 — 2021',
            'description': 'Character art, environments, and UI for AAA titles.',
          },
        ],
        'skills': ['Brand Identity', 'Illustration', 'Motion Design', 'Art Direction'],
        'education': [
          {
            'degree': 'BFA Visual Communication',
            'school': 'California College of the Arts',
            'year': '2016',
          },
        ],
        'testimonials': [
          {
            'quote':
                'Maya transformed our brand identity with artwork that feels alive.',
            'author': 'Sarah Okonkwo',
            'role': 'CMO, Lumina Studios',
            'rating': 5,
          },
          {
            'quote': 'Visionary, professional, and detail-oriented.',
            'author': 'James Rivera',
            'role': 'Lead Producer, PixelForge',
            'rating': 5,
          },
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _portfolioTertiary(int variant) => {
        'projects': [
          {
            'title': 'Neon Dreams Collection',
            'category': 'Digital Art',
            'year': '2025',
            'image': 'assets/images/project-1.jpg',
            'url': '#',
          },
          {
            'title': 'Aurora Brand System',
            'category': 'Branding',
            'year': '2024',
            'image': 'assets/images/project-2.jpg',
            'url': '#',
          },
          {
            'title': 'Echoes Game UI',
            'category': 'Game Art',
            'year': '2024',
            'image': 'assets/images/project-3.jpg',
            'url': '#',
          },
        ],
        'gallery': [
          {'image': 'assets/images/gallery-1.jpg', 'caption': 'Studio work'},
          {'image': 'assets/images/gallery-2.jpg', 'caption': 'Exhibition'},
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _businessPrimary(int variant) => {
        'businessName': 'Northline Studio',
        'tagline': 'Strategy, design, and digital growth',
        'logo': 'assets/images/logo.png',
        'address': '120 Market Street, San Francisco, CA 94105',
        'phone': '+1 (415) 555-0188',
        'email': 'hello@northline.studio',
        'mapEmbed':
            'https://maps.google.com/maps?q=120+Market+Street+San+Francisco&output=embed',
        'whatsapp': '+14155550188',
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _businessSecondary(int variant) => {
        'about':
            'Northline Studio partners with ambitious brands to build memorable digital experiences.',
        'services': [
          {'title': 'Brand Strategy', 'description': 'Positioning, messaging, and identity systems.'},
          {'title': 'Web Design', 'description': 'High-converting marketing and product sites.'},
          {'title': 'Growth Marketing', 'description': 'SEO, content, and paid acquisition.'},
        ],
        'achievements': [
          {'title': '120+ Launches', 'value': '2019—2026'},
          {'title': '4.9 Client Rating', 'value': 'Average score'},
        ],
        'testimonials': [
          {
            'quote': 'They delivered a site that doubled our inbound leads.',
            'author': 'Priya Mehta',
            'role': 'CEO, Bloom Health',
          },
        ],
        'team': [
          {'name': 'Alex Morgan', 'role': 'Founder', 'image': 'assets/images/team-1.jpg'},
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _businessTertiary(int variant) => {
        'gallery': [
          {'image': 'assets/images/gallery-1.jpg', 'title': 'Office'},
          {'image': 'assets/images/gallery-2.jpg', 'title': 'Workshop'},
        ],
        'products': [
          {'name': 'Brand Sprint', 'price': '\$2,500', 'image': 'assets/images/product-1.jpg'},
        ],
        'branches': [
          {
            'name': 'San Francisco HQ',
            'address': '120 Market Street',
            'phone': '+1 (415) 555-0188',
          },
          {
            'name': 'Austin Studio',
            'address': '400 Congress Ave',
            'phone': '+1 (512) 555-0144',
          },
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _giftPrimary(int variant) => {
        'title': 'A Special Surprise',
        'revealImages': [
          'assets/images/reveal-1.jpg',
          'assets/images/reveal-2.jpg',
        ],
        'coverImage': 'assets/images/gift-cover.jpg',
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _giftSecondary(int variant) => {
        'messages': [
          {'text': 'You mean the world to me.', 'delayMs': 0},
          {'text': 'Thank you for every moment together.', 'delayMs': 1200},
          {'text': 'Open your gift when the countdown ends.', 'delayMs': 2400},
        ],
        'countdownSeconds': 10,
        'musicUrl': 'assets/audio/reveal.mp3',
        'animation': _animationFor(variant),
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _giftTertiary(int variant) => {
        'finalMessage': 'Happy Anniversary! I love you.',
        'ctaLabel': 'Claim Your Gift',
        'ctaUrl': '#',
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _restaurantPrimary(int variant) => {
        'restaurantName': 'Ember & Oak',
        'tagline': 'Wood-fired flavors, modern comfort',
        'banners': [
          {
            'title': 'Weekend Brunch',
            'subtitle': 'Sat—Sun 9am—2pm',
            'image': 'assets/images/banner-1.jpg',
          },
          {
            'title': 'Chef\'s Tasting Menu',
            'subtitle': 'Seven courses · \$85',
            'image': 'assets/images/banner-2.jpg',
          },
        ],
        'offers': [
          {'label': '20% Off First Order', 'code': 'EMBER20'},
        ],
        'whatsapp': '+14155550199',
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _restaurantSecondary(int variant) => {
        'categories': [
          {'name': 'Starters', 'icon': 'starters'},
          {'name': 'Mains', 'icon': 'mains'},
          {'name': 'Desserts', 'icon': 'desserts'},
          {'name': 'Drinks', 'icon': 'drinks'},
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _restaurantTertiary(int variant) => {
        'menuItems': [
          {
            'name': 'Charred Octopus',
            'category': 'Starters',
            'price': 18,
            'description': 'Smoked paprika, lemon oil, herbs',
            'image': 'assets/images/menu-1.jpg',
            'spicy': false,
          },
          {
            'name': 'Oak-Fired Ribeye',
            'category': 'Mains',
            'price': 42,
            'description': 'Garlic butter, roasted roots',
            'image': 'assets/images/menu-2.jpg',
            'spicy': false,
          },
          {
            'name': 'Burnt Basque Cheesecake',
            'category': 'Desserts',
            'price': 12,
            'description': 'Seasonal berry compote',
            'image': 'assets/images/menu-3.jpg',
            'spicy': false,
          },
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _ecommercePrimary(int variant) => {
        'storeName': 'Atelier Home',
        'tagline': 'Curated furniture & decor',
        'banners': [
          {
            'title': 'Spring Collection',
            'subtitle': 'Fresh textures for modern living',
            'image': 'assets/images/banner-1.jpg',
          },
        ],
        'whatsapp': '+14155550200',
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _ecommerceSecondary(int variant) => {
        'categories': [
          {'name': 'Living Room', 'image': 'assets/images/cat-1.jpg'},
          {'name': 'Bedroom', 'image': 'assets/images/cat-2.jpg'},
          {'name': 'Kitchen', 'image': 'assets/images/cat-3.jpg'},
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _ecommerceTertiary(int variant) => {
        'products': [
          {
            'name': 'Linen Lounge Chair',
            'category': 'Living Room',
            'price': 349,
            'discount': 15,
            'image': 'assets/images/product-1.jpg',
            'description': 'Solid oak frame with breathable linen upholstery.',
          },
          {
            'name': 'Ceramic Table Lamp',
            'category': 'Living Room',
            'price': 89,
            'discount': 0,
            'image': 'assets/images/product-2.jpg',
            'description': 'Hand-glazed ceramic base with warm ambient glow.',
          },
          {
            'name': 'Walnut Sideboard',
            'category': 'Living Room',
            'price': 799,
            'discount': 10,
            'image': 'assets/images/product-3.jpg',
            'description': 'Minimal storage with soft-close drawers.',
          },
        ],
        'theme': _variantTheme(variant),
      };

  static Map<String, dynamic> _variantTheme(int variant) {
    final v = variant.clamp(1, 22);
    final palettes = [
      {'primary': '#6366F1', 'secondary': '#0F172A', 'accent': '#8B5CF6', 'background': '#FFFFFF', 'surface': '#F8FAFC', 'text': '#0F172A', 'layout': 'split', 'radius': 12, 'fontScale': 1.0, 'spacing': 16, 'heroStyle': 'left', 'cardStyle': 'elevated', 'navStyle': 'top', 'footerStyle': 'minimal', 'animation': 'fadeUp', 'secondaryLayout': 'cards', 'tertiaryLayout': 'grid'},
      {'primary': '#0EA5E9', 'secondary': '#334155', 'accent': '#06B6D4', 'background': '#F8FAFC', 'surface': '#FFFFFF', 'text': '#0F172A', 'layout': 'centered', 'radius': 0, 'fontScale': 1.05, 'spacing': 20, 'heroStyle': 'center', 'cardStyle': 'bordered', 'navStyle': 'sidebar', 'footerStyle': 'columns', 'animation': 'slideLeft', 'secondaryLayout': 'chips', 'tertiaryLayout': 'list'},
      {'primary': '#DC2626', 'secondary': '#0F172A', 'accent': '#FBBF24', 'background': '#FFFFFF', 'surface': '#FEF2F2', 'text': '#0F172A', 'layout': 'editorial', 'radius': 4, 'fontScale': 1.1, 'spacing': 18, 'heroStyle': 'overlap', 'cardStyle': 'flat', 'navStyle': 'sticky', 'footerStyle': 'dark', 'animation': 'clipReveal', 'secondaryLayout': 'timeline', 'tertiaryLayout': 'mosaic'},
      {'primary': '#10B981', 'secondary': '#064E3B', 'accent': '#34D399', 'background': '#F0FDF4', 'surface': '#FFFFFF', 'text': '#052E16', 'layout': 'grid', 'radius': 20, 'fontScale': 0.95, 'spacing': 14, 'heroStyle': 'fullBleed', 'cardStyle': 'glass', 'navStyle': 'bottom', 'footerStyle': 'compact', 'animation': 'zenRise', 'secondaryLayout': 'grid2', 'tertiaryLayout': 'cards'},
      {'primary': '#EC4899', 'secondary': '#831843', 'accent': '#F472B6', 'background': '#FFF1F2', 'surface': '#FFFFFF', 'text': '#500724', 'layout': 'bento', 'radius': 24, 'fontScale': 1.0, 'spacing': 12, 'heroStyle': 'card', 'cardStyle': 'soft', 'navStyle': 'pill', 'footerStyle': 'gradient', 'animation': 'bounceSoft', 'secondaryLayout': 'wrap', 'tertiaryLayout': 'featured'},
      {'primary': '#F59E0B', 'secondary': '#78350F', 'accent': '#FBBF24', 'background': '#FFFBEB', 'surface': '#FFFFFF', 'text': '#451A03', 'layout': 'magazine', 'radius': 8, 'fontScale': 1.08, 'spacing': 22, 'heroStyle': 'splitVertical', 'cardStyle': 'shadow', 'navStyle': 'underline', 'footerStyle': 'wide', 'animation': 'luxuryFade', 'secondaryLayout': 'rows', 'tertiaryLayout': 'catalog'},
      {'primary': '#000000', 'secondary': '#FFE500', 'accent': '#FFFFFF', 'background': '#F5F5F0', 'surface': '#FFFFFF', 'text': '#000000', 'layout': 'brutalist', 'radius': 0, 'fontScale': 1.15, 'spacing': 8, 'heroStyle': 'stacked', 'cardStyle': 'hard', 'navStyle': 'block', 'footerStyle': 'brutal', 'animation': 'brutalSnap', 'secondaryLayout': 'striped', 'tertiaryLayout': 'compact'},
      {'primary': '#4A7C59', 'secondary': '#2D4A3E', 'accent': '#86EFAC', 'background': '#F7F3EB', 'surface': '#FFFFFF', 'text': '#1C3829', 'layout': 'timeline', 'radius': 16, 'fontScale': 1.0, 'spacing': 20, 'heroStyle': 'curved', 'cardStyle': 'organic', 'navStyle': 'floating', 'footerStyle': 'nature', 'animation': 'zenRise', 'secondaryLayout': 'panel', 'tertiaryLayout': 'gallery'},
      {'primary': '#D4AF37', 'secondary': '#1C1917', 'accent': '#FAF8F5', 'background': '#FAF8F5', 'surface': '#FFFFFF', 'text': '#1C1917', 'layout': 'luxury', 'radius': 2, 'fontScale': 1.02, 'spacing': 24, 'heroStyle': 'marble', 'cardStyle': 'gold', 'navStyle': 'elegant', 'footerStyle': 'premium', 'animation': 'luxuryFade', 'secondaryLayout': 'quote', 'tertiaryLayout': 'showcase'},
      {'primary': '#00F5FF', 'secondary': '#050510', 'accent': '#FF006E', 'background': '#050510', 'surface': '#111827', 'text': '#F8FAFC', 'layout': 'cyber', 'radius': 6, 'fontScale': 0.98, 'spacing': 10, 'heroStyle': 'neon', 'cardStyle': 'neon', 'navStyle': 'terminal', 'footerStyle': 'grid', 'animation': 'glitchSnap', 'secondaryLayout': 'tags', 'tertiaryLayout': 'price'},
      {'primary': '#3D3D3D', 'secondary': '#2A2A2A', 'accent': '#FFFFFF', 'background': '#2A2A2A', 'surface': '#3D3D3D', 'text': '#FFFFFF', 'layout': 'monochrome', 'radius': 0, 'fontScale': 1.0, 'spacing': 16, 'heroStyle': 'monochromeSplit', 'cardStyle': 'line', 'navStyle': 'minimal', 'footerStyle': 'mono', 'animation': 'slideLeft', 'secondaryLayout': 'minimal', 'tertiaryLayout': 'stack'},
      {'primary': '#7C3AED', 'secondary': '#4C1D95', 'accent': '#C4B5FD', 'background': '#FAF5FF', 'surface': '#FFFFFF', 'text': '#2E1065', 'layout': 'ribbon', 'radius': 14, 'fontScale': 1.0, 'spacing': 16, 'heroStyle': 'ribbon', 'cardStyle': 'elevated', 'navStyle': 'tabs', 'footerStyle': 'split', 'animation': 'fadeUp', 'secondaryLayout': 'accent', 'tertiaryLayout': 'wide'},
      {'primary': '#0891B2', 'secondary': '#164E63', 'accent': '#67E8F9', 'background': '#ECFEFF', 'surface': '#FFFFFF', 'text': '#083344', 'layout': 'inset', 'radius': 10, 'fontScale': 0.97, 'spacing': 18, 'heroStyle': 'inset', 'cardStyle': 'bordered', 'navStyle': 'segmented', 'footerStyle': 'inline', 'animation': 'slideLeft', 'secondaryLayout': 'float', 'tertiaryLayout': 'dense'},
      {'primary': '#BE123C', 'secondary': '#881337', 'accent': '#FDA4AF', 'background': '#FFF1F2', 'surface': '#FFFFFF', 'text': '#4C0519', 'layout': 'dual', 'radius': 6, 'fontScale': 1.06, 'spacing': 14, 'heroStyle': 'dual', 'cardStyle': 'flat', 'navStyle': 'drawer', 'footerStyle': 'dark', 'animation': 'clipReveal', 'secondaryLayout': 'dense', 'tertiaryLayout': 'banner'},
      {'primary': '#059669', 'secondary': '#047857', 'accent': '#6EE7B7', 'background': '#FFFFFF', 'surface': '#F0FDF4', 'text': '#064E3B', 'layout': 'compact', 'radius': 18, 'fontScale': 0.92, 'spacing': 12, 'heroStyle': 'compact', 'cardStyle': 'soft', 'navStyle': 'icon', 'footerStyle': 'compact', 'animation': 'bounceSoft', 'secondaryLayout': 'inline', 'tertiaryLayout': 'inline'},
      {'primary': '#2563EB', 'secondary': '#1E3A8A', 'accent': '#93C5FD', 'background': '#EFF6FF', 'surface': '#FFFFFF', 'text': '#1E3A8A', 'layout': 'wide', 'radius': 8, 'fontScale': 1.12, 'spacing': 24, 'heroStyle': 'wide', 'cardStyle': 'shadow', 'navStyle': 'wide', 'footerStyle': 'wide', 'animation': 'luxuryFade', 'secondaryLayout': 'hero', 'tertiaryLayout': 'hero'},
      {'primary': '#9333EA', 'secondary': '#581C87', 'accent': '#E9D5FF', 'background': '#FAF5FF', 'surface': '#FFFFFF', 'text': '#3B0764', 'layout': 'pill', 'radius': 999, 'fontScale': 1.0, 'spacing': 14, 'heroStyle': 'pill', 'cardStyle': 'soft', 'navStyle': 'pill', 'footerStyle': 'gradient', 'animation': 'zenRise', 'secondaryLayout': 'wrap', 'tertiaryLayout': 'tiles'},
      {'primary': '#EA580C', 'secondary': '#9A3412', 'accent': '#FDBA74', 'background': '#FFF7ED', 'surface': '#FFFFFF', 'text': '#7C2D12', 'layout': 'shadow', 'radius': 16, 'fontScale': 1.0, 'spacing': 16, 'heroStyle': 'shadow', 'cardStyle': 'shadow', 'navStyle': 'sticky', 'footerStyle': 'columns', 'animation': 'brutalSnap', 'secondaryLayout': 'stack', 'tertiaryLayout': 'rows'},
      {'primary': '#475569', 'secondary': '#1E293B', 'accent': '#94A3B8', 'background': '#F1F5F9', 'surface': '#FFFFFF', 'text': '#0F172A', 'layout': 'line', 'radius': 4, 'fontScale': 1.0, 'spacing': 20, 'heroStyle': 'underline', 'cardStyle': 'line', 'navStyle': 'underline', 'footerStyle': 'minimal', 'animation': 'fadeUp', 'secondaryLayout': 'list', 'tertiaryLayout': 'list'},
      {'primary': '#B45309', 'secondary': '#78350F', 'accent': '#FCD34D', 'background': '#FFFBEB', 'surface': '#FFFFFF', 'text': '#451A03', 'layout': 'bold', 'radius': 0, 'fontScale': 1.2, 'spacing': 10, 'heroStyle': 'bold', 'cardStyle': 'hard', 'navStyle': 'block', 'footerStyle': 'brutal', 'animation': 'glitchSnap', 'secondaryLayout': 'boxed', 'tertiaryLayout': 'focus'},
      {'primary': '#DB2777', 'secondary': '#831843', 'accent': '#F9A8D4', 'background': '#FDF2F8', 'surface': '#FFFFFF', 'text': '#500724', 'layout': 'soft', 'radius': 28, 'fontScale': 0.96, 'spacing': 18, 'heroStyle': 'soft', 'cardStyle': 'glass', 'navStyle': 'floating', 'footerStyle': 'nature', 'animation': 'bounceSoft', 'secondaryLayout': 'spaced', 'tertiaryLayout': 'strip'},
      {'primary': '#0F766E', 'secondary': '#134E4A', 'accent': '#5EEAD4', 'background': '#FFFFFF', 'surface': '#F0FDFA', 'text': '#042F2E', 'layout': 'edge', 'radius': 0, 'fontScale': 1.04, 'spacing': 12, 'heroStyle': 'edge', 'cardStyle': 'bordered', 'navStyle': 'overlay', 'footerStyle': 'premium', 'animation': 'slideLeft', 'secondaryLayout': 'columns', 'tertiaryLayout': 'split'},
    ];
    final base = Map<String, dynamic>.from(palettes[v - 1]);
    base['variant'] = v;
    return base;
  }

  static String _animationFor(int variant) {
    const animations = [
      'confetti', 'fadeSequence', 'zoomReveal', 'slideUp', 'heartBurst', 'sparkle',
      'flipCard', 'curtain', 'typewriter', 'balloon', 'fireworks', 'shimmer',
      'pulse', 'rotate', 'bounce', 'wave', 'glow', 'rain', 'stars', 'ribbonDrop',
      'cascade', 'spotlight',
    ];
    return animations[(variant.clamp(1, 22) - 1)];
  }
}
