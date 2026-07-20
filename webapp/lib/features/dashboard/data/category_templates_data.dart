import 'package:webapp/features/dashboard/models/category_template.dart';

/// Static local templates for all categories (not Supabase — code only).
abstract final class CategoryTemplatesData {
  static const List<CategoryTemplate> all = [
    ecommerce,
    portfolio,
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

  static const CategoryTemplate portfolio = CategoryTemplate(
    type: CategoryType.portfolio,
    templateType: 1,
    name: 'Creative Portfolio',
    subname: 'Showcase your work',
    description:
        'Present projects, skills, and highlights with a clean portfolio layout.',
    data: [
      CategoryContentBlock(seqId: 1, contentType: ContentType.banners),
      CategoryContentBlock(seqId: 2, contentType: ContentType.categories),
      CategoryContentBlock(seqId: 3, contentType: ContentType.products),
    ],
  );

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

  static CategoryTemplate? byType(int type) {
    for (final template in all) {
      if (template.type == type) return template;
    }
    return null;
  }
}
