import 'package:flutter/material.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/templates/catalog/default_content_factory.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

/// Visual accent metadata for template picker cards.
class TemplateStyle {
  const TemplateStyle({
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

class TemplateDefinition {
  const TemplateDefinition({
    required this.type,
    required this.templateType,
    required this.name,
    required this.subname,
    required this.description,
    required this.style,
  });

  final int type;
  final int templateType;
  final String name;
  final String subname;
  final String description;
  final TemplateStyle style;

  WebsiteDocument toDocument() {
    return WebsiteDocument(
      type: type,
      templateType: templateType,
      name: name,
      subname: subname,
      description: description,
      logo: 'assets/images/logo.png',
      data: DefaultContentFactory.blocksForCategory(type, templateType),
    );
  }
}

/// 110 production templates — 22 per category.
abstract final class TemplateCatalog {
  static const int templatesPerCategory = 22;

  static List<TemplateDefinition> forCategory(int type) {
    return all.where((template) => template.type == type).toList();
  }

  static TemplateDefinition? byTypeAndTemplate(int type, int templateType) {
    for (final template in all) {
      if (template.type == type && template.templateType == templateType) {
        return template;
      }
    }
    return null;
  }

  static TemplateDefinition defaultForCategory(int type) {
    return forCategory(type).first;
  }

  static TemplateStyle styleFor(WebsiteDocument document) {
    final template = byTypeAndTemplate(document.type, document.templateType);
    return template?.style ?? all.first.style;
  }

  static List<TemplateDefinition> get all => [
        ..._categoryTemplates(CategoryType.portfolio, _portfolioNames),
        ..._categoryTemplates(CategoryType.businessProfile, _businessNames),
        ..._categoryTemplates(CategoryType.giftReveal, _giftNames),
        ..._categoryTemplates(CategoryType.restaurantMenu, _restaurantNames),
        ..._categoryTemplates(CategoryType.ecommerce, _ecommerceNames),
      ];

  static List<TemplateDefinition> _categoryTemplates(
    int type,
    List<_TemplateMeta> metas,
  ) {
    return [
      for (var i = 0; i < metas.length; i++)
        TemplateDefinition(
          type: type,
          templateType: i + 1,
          name: metas[i].name,
          subname: metas[i].subname,
          description: metas[i].description,
          style: _styleFor(type, i + 1),
        ),
    ];
  }

  static TemplateStyle _styleFor(int type, int templateType) {
    final theme = DefaultContentFactory.primaryFor(type, templateType)['theme']
        as Map<String, dynamic>?;
    final primary = _colorFromHex(theme?['primary'] as String?, const Color(0xFF6366F1));
    final secondary = _colorFromHex(theme?['secondary'] as String?, const Color(0xFF0F172A));
    final accent = _colorFromHex(theme?['accent'] as String?, const Color(0xFF8B5CF6));
    return TemplateStyle(
      primary: primary,
      secondary: secondary,
      accent: accent,
      previewGradient: [primary, secondary],
      icon: _iconFor(type, templateType),
    );
  }

  static Color _colorFromHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final value = hex.replaceFirst('#', '');
    if (value.length == 6) {
      return Color(int.parse('FF$value', radix: 16));
    }
    return fallback;
  }

  static IconData _iconFor(int type, int templateType) {
    final icons = switch (type) {
      CategoryType.portfolio => [
        Icons.view_column_outlined,
        Icons.terminal_rounded,
        Icons.horizontal_rule_rounded,
        Icons.movie_filter_outlined,
        Icons.format_quote_rounded,
        Icons.blur_on_rounded,
        Icons.grid_4x4_rounded,
        Icons.cloud_rounded,
        Icons.crop_square_rounded,
        Icons.eco_outlined,
        Icons.diamond_outlined,
        Icons.palette_outlined,
        Icons.layers_outlined,
        Icons.auto_awesome_mosaic_outlined,
        Icons.view_quilt_outlined,
        Icons.dashboard_customize_outlined,
        Icons.brush_outlined,
        Icons.camera_roll_outlined,
        Icons.design_services_outlined,
        Icons.lightbulb_outline,
        Icons.architecture_outlined,
        Icons.collections_outlined,
      ],
      CategoryType.businessProfile => [
        Icons.business_center_outlined,
        Icons.apartment_outlined,
        Icons.storefront_outlined,
        Icons.handshake_outlined,
        Icons.groups_outlined,
        Icons.public_outlined,
        Icons.location_city_outlined,
        Icons.work_outline,
        Icons.corporate_fare_outlined,
        Icons.domain_outlined,
        Icons.account_balance_outlined,
        Icons.verified_outlined,
        Icons.trending_up_outlined,
        Icons.support_agent_outlined,
        Icons.badge_outlined,
        Icons.contact_page_outlined,
        Icons.map_outlined,
        Icons.phone_in_talk_outlined,
        Icons.star_outline,
        Icons.insights_outlined,
        Icons.hub_outlined,
      ],
      CategoryType.giftReveal => [
        Icons.card_giftcard_outlined,
        Icons.favorite_outline,
        Icons.celebration_outlined,
        Icons.auto_fix_high_outlined,
        Icons.redeem_outlined,
        Icons.emoji_emotions_outlined,
        Icons.music_note_outlined,
        Icons.hourglass_empty_outlined,
        Icons.mail_outline,
        Icons.volunteer_activism_outlined,
        Icons.cake_outlined,
        Icons.local_florist_outlined,
        Icons.nightlight_outlined,
        Icons.wb_sunny_outlined,
        Icons.spa_outlined,
        Icons.sentiment_very_satisfied_outlined,
        Icons.diamond_outlined,
        Icons.stars_outlined,
        Icons.theater_comedy_outlined,
        Icons.air_outlined,
        Icons.bubble_chart_outlined,
        Icons.blur_circular_outlined,
      ],
      CategoryType.restaurantMenu => [
        Icons.restaurant_menu,
        Icons.local_dining_outlined,
        Icons.ramen_dining_outlined,
        Icons.set_meal_outlined,
        Icons.local_pizza_outlined,
        Icons.icecream_outlined,
        Icons.local_bar_outlined,
        Icons.emoji_food_beverage_outlined,
        Icons.outdoor_grill_outlined,
        Icons.bakery_dining_outlined,
        Icons.breakfast_dining_outlined,
        Icons.lunch_dining_outlined,
        Icons.dinner_dining_outlined,
        Icons.room_service_outlined,
        Icons.menu_book_outlined,
        Icons.flatware_outlined,
        Icons.wine_bar_outlined,
        Icons.coffee_outlined,
        Icons.fastfood_outlined,
        Icons.kebab_dining_outlined,
        Icons.rice_bowl_outlined,
        Icons.takeout_dining_outlined,
      ],
      CategoryType.ecommerce => [
        Icons.shopping_bag_outlined,
        Icons.storefront_outlined,
        Icons.shopping_cart_outlined,
        Icons.inventory_2_outlined,
        Icons.local_mall_outlined,
        Icons.sell_outlined,
        Icons.discount_outlined,
        Icons.category_outlined,
        Icons.view_module_outlined,
        Icons.grid_view_outlined,
        Icons.chair_outlined,
        Icons.watch_outlined,
        Icons.checkroom_outlined,
        Icons.devices_outlined,
        Icons.kitchen_outlined,
        Icons.sports_outlined,
        Icons.toys_outlined,
        Icons.pets_outlined,
        Icons.eco_outlined,
        Icons.diamond_outlined,
        Icons.home_outlined,
        Icons.card_membership_outlined,
      ],
      _ => [Icons.web_outlined],
    };
    return icons[(templateType - 1) % icons.length];
  }

  static const _portfolioNames = [
    _TemplateMeta('Split Monochrome', 'Editorial B&W', 'Square portrait split-screen with gray editorial panel.'),
    _TemplateMeta('Dark Dev', 'Developer portfolio', 'Black hero with purple accent and profile photo.'),
    _TemplateMeta('Swiss Minimal', 'Typography-first', 'Ultra-clean whitespace and numbered testimonials.'),
    _TemplateMeta('Noir Cinema', 'Film & photo', 'Cinematic black with gold frames and widescreen banners.'),
    _TemplateMeta('Editorial Magazine', 'Bold editorial', 'Red/yellow split blocks with pull quotes.'),
    _TemplateMeta('Aurora Glass', 'Glassmorphism', 'Frosted cards on aurora gradients with blur motion.'),
    _TemplateMeta('Neon Cyber', 'Cyberpunk grid', 'Neon borders, terminal typography, glitch entrances.'),
    _TemplateMeta('Pastel Dream', 'Soft & friendly', 'Pastel bubbles, bento grid, bounce animations.'),
    _TemplateMeta('Brutalist', 'Raw & bold', 'Harsh contrast blocks, zero radius, snap animations.'),
    _TemplateMeta('Nature Zen', 'Organic calm', 'Sage greens, curved hero, timeline projects.'),
    _TemplateMeta('Luxury Gold', 'Premium elegance', 'Marble tones, gold accents, refined fade motion.'),
    _TemplateMeta('Canvas Flow', 'Gallery-first', 'Full-width gallery grid with floating captions.'),
    _TemplateMeta('Studio Bold', 'Agency style', 'Oversized type, stacked sections, bold CTAs.'),
    _TemplateMeta('Minimal Grid', 'Structured', 'Three-column project grid with thin dividers.'),
    _TemplateMeta('Creative Wave', 'Organic motion', 'Curved section dividers and layered hero cards.'),
    _TemplateMeta('Metro Split', 'Dual column', 'Split hero with timeline experience rail.'),
    _TemplateMeta('Portfolio Prism', 'Color blocks', 'Diagonal color panels and mosaic gallery.'),
    _TemplateMeta('Focus Frame', 'Photo-led', 'Large framed portrait with sidebar navigation.'),
    _TemplateMeta('Modern Resume', 'CV layout', 'Resume sections with downloadable PDF CTA.'),
    _TemplateMeta('Artisan Craft', 'Handmade feel', 'Paper textures, serif headings, project cards.'),
    _TemplateMeta('Tech Stack', 'Engineer', 'Terminal-inspired skills matrix and repo links.'),
    _TemplateMeta('Showcase Pro', 'Conversion', 'Hero CTA, testimonials carousel, project filters.'),
  ];

  static const _businessNames = [
    _TemplateMeta('Corporate Edge', 'Professional', 'Split hero with map and contact bar.'),
    _TemplateMeta('Trust Builder', 'Services-led', 'Service cards with achievement counters.'),
    _TemplateMeta('Local Hero', 'Community', 'Branch locator and testimonial strip.'),
    _TemplateMeta('Consult Pro', 'Advisory', 'Timeline achievements and team grid.'),
    _TemplateMeta('Studio Launch', 'Creative agency', 'Gallery masonry and bold typography.'),
    _TemplateMeta('Clinic Care', 'Healthcare', 'Clean panels, appointment phone CTA.'),
    _TemplateMeta('Legal Firm', 'Formal', 'Serif headings, credentials, office branches.'),
    _TemplateMeta('Real Estate', 'Property', 'Gallery-forward listings and map embed.'),
    _TemplateMeta('Fitness Hub', 'Active brand', 'High-energy hero and service tiers.'),
    _TemplateMeta('Salon Luxe', 'Beauty', 'Soft gradients, gallery, booking WhatsApp.'),
    _TemplateMeta('Auto Works', 'Industrial', 'Dark steel palette with service icons.'),
    _TemplateMeta('Edu Center', 'Learning', 'Course-style services and testimonials.'),
    _TemplateMeta('Finance Pro', 'Corporate trust', 'Numbers-first hero and client logos row.'),
    _TemplateMeta('Travel Desk', 'Hospitality', 'Destination gallery and branch cards.'),
    _TemplateMeta('Build Co', 'Construction', 'Project gallery and rugged typography.'),
    _TemplateMeta('Pet Care', 'Friendly', 'Rounded cards, team photos, warm palette.'),
    _TemplateMeta('Event Co', 'Celebrations', 'Portfolio gallery and testimonial slider.'),
    _TemplateMeta('Clean Co', 'Services', 'Icon grid services and WhatsApp quote CTA.'),
    _TemplateMeta('Tech Partner', 'B2B SaaS', 'Feature columns and case-study cards.'),
    _TemplateMeta('Retail Chain', 'Multi-branch', 'Branch tabs and product highlights.'),
    _TemplateMeta('Nonprofit', 'Mission', 'Story-first about and impact stats.'),
    _TemplateMeta('Startup Pitch', 'Launch', 'Bold hero, milestones, investor-ready layout.'),
  ];

  static const _giftNames = [
    _TemplateMeta('Heart Reveal', 'Romantic', 'Countdown with heart animation and music.'),
    _TemplateMeta('Confetti Pop', 'Celebration', 'Confetti burst and sequenced messages.'),
    _TemplateMeta('Midnight Surprise', 'Dark mode', 'Starfield background and glowing text.'),
    _TemplateMeta('Golden Moment', 'Luxury', 'Gold accents with curtain reveal animation.'),
    _TemplateMeta('Birthday Bash', 'Party', 'Balloon animation and bright palette.'),
    _TemplateMeta('Anniversary', 'Classic', 'Photo slideshow and love letter messages.'),
    _TemplateMeta('Proposal', 'Emotional', 'Slow reveal with final ring message.'),
    _TemplateMeta('Thank You', 'Gratitude', 'Minimal cards and gentle fade sequence.'),
    _TemplateMeta('New Baby', 'Soft pastel', 'Pastel clouds and lullaby music slot.'),
    _TemplateMeta('Graduation', 'Achievement', 'Cap animation and proud message stack.'),
    _TemplateMeta('Holiday Magic', 'Seasonal', 'Snow overlay and gift box reveal.'),
    _TemplateMeta('Friendship', 'Playful', 'Sticker-style messages and bounce motion.'),
    _TemplateMeta('Apology Note', 'Sincere', 'Typewriter text and soft piano slot.'),
    _TemplateMeta('Secret Message', 'Mystery', 'Locked countdown and decode animation.'),
    _TemplateMeta('Photo Memory', 'Gallery', 'Polaroid stack reveal with captions.'),
    _TemplateMeta('Fireworks Night', 'Spectacle', 'Fireworks animation and bold finale.'),
    _TemplateMeta('Love Letter', 'Vintage', 'Paper texture, serif type, wax seal motif.'),
    _TemplateMeta('Surprise Trip', 'Travel', 'Ticket-style reveal and destination photos.'),
    _TemplateMeta('Well Wishes', 'Support', 'Calm palette and encouraging messages.'),
    _TemplateMeta('Team Thanks', 'Workplace', 'Card grid messages and team photos.'),
    _TemplateMeta('Custom Gift', 'Flexible', 'Configurable blocks for any occasion.'),
    _TemplateMeta('Grand Finale', 'Cinematic', 'Multi-stage animation with music and CTA.'),
  ];

  static const _restaurantNames = [
    _TemplateMeta('Ember Grill', 'Wood-fired', 'Hero offers, category tabs, menu cards.'),
    _TemplateMeta('Sushi Bar', 'Japanese', 'Minimal menu rows and chef specials banner.'),
    _TemplateMeta('Pizza House', 'Casual', 'Bold category chips and photo menu grid.'),
    _TemplateMeta('Cafe Bloom', 'Coffee', 'Pastel hero, drink categories, pastry menu.'),
    _TemplateMeta('Fine Dining', 'Elegant', 'Dark luxury menu with course sections.'),
    _TemplateMeta('Street Food', 'Urban', 'Neon accents and compact menu list.'),
    _TemplateMeta('Bakery Fresh', 'Warm', 'Rounded cards and daily offers strip.'),
    _TemplateMeta('Healthy Bowl', 'Clean', 'Green palette, macro tags on menu items.'),
    _TemplateMeta('BBQ Pit', 'Rustic', 'Smoky textures and combo meal cards.'),
    _TemplateMeta('Seafood Dock', 'Coastal', 'Blue palette, catch-of-the-day banner.'),
    _TemplateMeta('Vegan Garden', 'Plant-based', 'Organic layout and ingredient badges.'),
    _TemplateMeta('Dessert Lab', 'Sweet', 'Pink hero and dessert category carousel.'),
    _TemplateMeta('Wine & Dine', 'Bistro', 'Wine list section and pairing suggestions.'),
    _TemplateMeta('Brunch Club', 'Morning', 'Split hero hours and brunch menu grid.'),
    _TemplateMeta('Tapas Social', 'Sharing', 'Small plates grid with spicy indicators.'),
    _TemplateMeta('Steakhouse', 'Premium', 'Dark red theme and cut pricing table.'),
    _TemplateMeta('Food Truck', 'Mobile', 'Compact vertical menu and location banner.'),
    _TemplateMeta('Family Kitchen', 'Homestyle', 'Comfort food cards and family offers.'),
    _TemplateMeta('Rooftop Bar', 'Nightlife', 'Gradient hero and cocktail categories.'),
    _TemplateMeta('Indian Spice', 'Spiced', 'Warm colors and thali combo sections.'),
    _TemplateMeta('Thai Street', 'Bold', 'Icon categories and spicy menu badges.'),
    _TemplateMeta('Order Fast', 'WhatsApp', 'Sticky order bar and category quick nav.'),
  ];

  static const _ecommerceNames = [
    _TemplateMeta('Atelier Home', 'Furniture', 'Hero banner, category grid, product cards.'),
    _TemplateMeta('Fashion Loft', 'Apparel', 'Editorial hero and lookbook categories.'),
    _TemplateMeta('Gadget Store', 'Electronics', 'Spec-focused product cards and filters.'),
    _TemplateMeta('Beauty Bar', 'Cosmetics', 'Soft gradients and routine categories.'),
    _TemplateMeta('Kids Corner', 'Toys', 'Playful colors and age category chips.'),
    _TemplateMeta('Sports Gear', 'Active', 'Bold hero and performance product grid.'),
    _TemplateMeta('Organic Market', 'Grocery', 'Fresh palette and category aisles.'),
    _TemplateMeta('Jewelry Lux', 'Premium', 'Dark gold theme and showcase products.'),
    _TemplateMeta('Pet Shop', 'Friendly', 'Rounded product cards and pet categories.'),
    _TemplateMeta('Book Nook', 'Books', 'Shelf-style categories and cover-forward grid.'),
    _TemplateMeta('Handmade', 'Craft', 'Artisan story hero and maker products.'),
    _TemplateMeta('Minimal Store', 'Clean', 'Whitespace product grid and thin typography.'),
    _TemplateMeta('Flash Sale', 'Promo', 'Discount badges and urgency banners.'),
    _TemplateMeta('Catalog Pro', 'B2B', 'Table-style product list with WhatsApp quote.'),
    _TemplateMeta('Dark Shop', 'Modern', 'Dark mode storefront and neon accents.'),
    _TemplateMeta('Grid Market', 'Multi-category', 'Dense grid and sidebar categories.'),
    _TemplateMeta('Single Brand', 'D2C', 'Brand story hero and flagship products.'),
    _TemplateMeta('Seasonal Drop', 'Limited', 'Campaign banner and drop countdown.'),
    _TemplateMeta('Compare Kit', 'Specs', 'Comparison-friendly product cards.'),
    _TemplateMeta('Bundle Store', 'Offers', 'Bundle pricing and category combos.'),
    _TemplateMeta('Local Seller', 'Community', 'Seller intro and neighborhood categories.'),
    _TemplateMeta('WhatsCart', 'Conversion', 'Sticky cart bar and WhatsApp checkout.'),
  ];
}

class _TemplateMeta {
  const _TemplateMeta(this.name, this.subname, this.description);

  final String name;
  final String subname;
  final String description;
}
